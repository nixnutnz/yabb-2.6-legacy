###############################################################################
# MyCenter.pl                                                                 #
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
# use strict;
# use warnings;
no warnings qw(uninitialized once);
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = 1.92;

$mycenterplver = 'YaBB 2.5.4 $Revision: 1.92 $';
if ($action eq 'detailedversion') { return 1; }

LoadLanguage('InstantMessage');
LoadLanguage('MyCenter');
require "$templatesdir/$usemycenter/MyCenter.template";
if (-e "$vardir/gmodsettings.txt" && $iamgmod) { 
    require "$vardir/gmodsettings.txt";
}
$mycenter_txt{'welcometxt'} =~ s/USERLABEL/${$uid.$username}{'realname'}/gxsm;

$showIM = q{};
$IM_box = q{};
$showProfile = q{};
$PMfileToOpen = q{};
$sendBMess = q{};
$isBMess = q{};
$showFavorites = q{};
$showNotifications = q{};

sub mycenter {
    if ($iamguest) { fatal_error('im_members_only'); }

	LoadBroadcastMessages($username); # get the BM infos

	$IM_box = q{};
	my $PMfileToOpen = q{};
	my @otherStoreFolders = ();
	my $otherStoreSelect = q{};
	$replyguest = $INFO{'replyguest'} || $FORM{'replyguest'};
	## select view by action
    if (   $action =~ /^im/sm
        || $action eq 'deletemultimessages'
        || $action eq 'pmsearch' )
    {
        $view = 'pm';
    }
	elsif ($action eq 'mycenter') { $view = 'mycenter'; }
    elsif ($action eq 'shownotify'
        || $action =~ /^notify/xsm
        || $action eq 'boardnotify2' )
    {
        $view    = 'notify';
        $mctitle = $img_txt{'418'};
    }
	elsif ($action eq 'myusersrecentposts') { $view = 'recentposts'; }
    elsif ( $action eq 'favorites' ) {
        $view    = 'favorites';
        $mctitle = $img_txt{'70'};
    }
    elsif ( $action =~ /^my/xsm ) { $view = 'profile'; }
	## viewing PMs
	if ($view eq 'pm') { # pm views
		## viewing a message box
		require "$sourcedir/InstantMessage.pl";
        if (   $action eq 'im'
            || $action eq 'imoutbox'
            || $action eq 'imstorage' )
        {
			my $foundextra = 0;
            foreach my $storefolder ( split /\|/xsm, ${$username}{'PMfolders'} )
            {
				if($storefolder ne $INFO{'viewfolder'}) {
                    push @otherStoreFolders, $storefolder;
					$foundextra = 1;
				}
			}
			if ($foundextra > 0) {
                $otherStoreSelect =
qq~ $inmes_txt{'storein'} <select name="tostorefolder" id="tostorefolder">~;
				foreach my $otherFolder (@otherStoreFolders) {
					my $otherFolderName = $otherFolder;
                    if ( $otherFolder eq 'in' ) {
                        $otherFolderName = $im_folders_txt{'in'};
                    }
                    elsif ( $otherFolder eq 'out' ) {
                        $otherFolderName = $im_folders_txt{'out'};
                    }
                    $otherStoreSelect .=
qq~<option value="$otherFolder">$otherFolderName</option>~;
				}
				$otherStoreSelect .= q~</select>~;
			}
		}
		## inbox
        if ( $action eq 'im'
            || ( $action eq 'imshow' && $INFO{'caller'} == 1 ) )
        {
			$mctitle = $inmes_txt{'inbox'};
			$status = $inmes_imtxt{'status'};
			$senderinfo = $inmes_txt{'318'};
			$callerid = 1;
			$boxtxt = $inmes_txt{'316'};
            $movebutton =
qq~<input type="submit" name="imaction" value="$inmes_imtxt{'store'}" class="button" />$otherStoreSelect $inmes_txt{'storeor'}~;
			$IM_box = $inmes_txt{'inbox'};
			if ( $INFO{'focus'} eq 'bmess' || $INFO{'bmess'} eq 'yes') {
                $IM_box = $inmes_txt{'broadcast'};
                $callerid = 5;
            }
			$PMfileToOpen = 'msg';
		}
		##  draft box
		elsif ($action eq 'imdraft') {
			$mctitle = $inmes_txt{'draft'};
			$status = $inmes_imtxt{'status'};
			$senderinfo = $inmes_txt{'324'};
			$callerid = 4;
			$boxtxt = $inmes_txt{'draft'};
            $movebutton   = q{};
			$IM_box = $inmes_txt{'draft'};
			$PMfileToOpen = 'imdraft';
		}
		## outbox
		elsif ($action eq 'imoutbox'
            || ( $action eq 'imshow' && $INFO{'caller'} == 2 ) )
        {
			$mctitle = $inmes_txt{'773'};
			$status = $inmes_imtxt{'status'};
			$senderinfo = $inmes_txt{'324'};
			$callerid = 2;
			$boxtxt = $inmes_txt{'outbox'};
			$movebutton  =
qq~<input type="submit" name="imaction" value="$inmes_imtxt{'store'}" class="button" />$otherStoreSelect $inmes_txt{'storeor'}~;
			$IM_box = $inmes_txt{'outbox'};
			$PMfileToOpen = 'outbox';
		}

		# store
		elsif ( $action eq 'imstorage'
            || ($action eq 'imshow' && $INFO{'caller'} == 3 ) )
       {
			$mctitle = $inmes_txt{'storage'};
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
qq~<input type="submit" name="imaction" value="$inmes_imtxt{'store'}" class="button" />$otherStoreSelect $inmes_txt{'storeor'}~;
			$IM_box = $inmes_txt{'storage'};

		    fopen( THREADS, "$memberdir/$username.imstore" );
	        @threads = <THREADS>;
	        fclose(THREADS);
		    $threadid = $INFO{'id'};
		    foreach my $thread (@threads) { 
	    	    chomp $thread;
	    	    if ( $thread =~ /$threadid/ ) {
		    	    @fold = split /\|/xsm, $thread;
		    	    if ( $fold[13] eq 'in' || $fold[13] eq 'out') {
		    	        $folder = qq~$im_folders_txt{$fold[13]}~;
		    	    }
		    	    else { $folder = $fold[13]; }
			    }
		    }
            if ( $INFO{'viewfolder'} eq 'in' || $INFO{'viewfolder'} eq 'out' ) {
                $IM_box .= qq~ &rsaquo; $im_folders_txt{"$INFO{'viewfolder'}"}~;
            }
            elsif ( $INFO{'viewfolder'} ) {
                $IM_box .= qq~ &rsaquo; $INFO{'viewfolder'}~;
            }
            $mctitle .= qq~ &rsaquo; $folder~;
			$PMfileToOpen = 'imstore';
		}
		## sending a message / previewing
        elsif ( $action eq 'imsend'
            || ( $action eq 'imsend2' && $FORM{'previewim'} ) )
        {
			$IM_box = $inmes_txt{'148'};
			if ($INFO{'forward'} == 1) { $IM_box = $inmes_txt{'forward'}; }
			if ($INFO{'reply'}) { $IM_box = $inmes_txt{'replymess'}; }
            IMPost();
            buildIMsend();
            doshowims();
		}
		## posting the message or draft
		elsif ($action eq 'imsend2' || $FORM{'draft'}) {
			$IM_box = $inmes_txt{'148'};
			if($INFO{'forward'} == 1) { $IM_box = $inmes_txt{'forward'}; }
			if($INFO{'reply'}) { $IM_box = $inmes_txt{'replymess'}; }
            IMsendMessage();
		}
		elsif ($action eq 'imshow' && $INFO{'caller'} == 5) {
			$mctitle = $inmes_txt{'broadcast'};
			$status = $inmes_imtxt{'status'};
			$senderinfo = $inmes_txt{'318'};
			$callerid = 5;
			$boxtxt = $inmes_txt{'316'};
            $movebutton =
qq~<input type="submit" name="imaction" value="$inmes_imtxt{'store'}" class="button" />$otherStoreSelect $inmes_txt{'storeor'}~;
			$IM_box = $inmes_txt{'broadcast'};
			$PMfileToOpen = 'msg';
		}
	}
	## viewing front page
	elsif ($view eq 'mycenter') {
		$mctitle = "$inmes_txt{'mycenter'}";
	}
	## viewing my profile
	elsif ($view eq 'profile') {
		$mctitle = "$mc_menus{'profile'}";
	}
	## viewing my recent posts
	elsif ($view eq 'recentposts') {
        $mctitle =
          "$inmes_txt{'viewrecentposts'} $inmes_txt{'viewrecentposts2'}";
	}

	## draw the container
	drawPMbox($PMfileToOpen);
	LoadIMs();

	# navigation link
    $yynavigation =
qq~&rsaquo; <a href="$scripturl?action=mycenter" class="nav">$img_txt{'mycenter'}</a> &rsaquo; $mctitle~;

	## set template up
    $mycenter_template =~ s/({|<)yabb mcviewmenu(}|>)/$MCViewMenu/gsm;
    $mycenter_template =~ s/({|<)yabb mcmenu(}|>)/$yymcmenu/gsm;
    $mycenter_template =~ s/({|<)yabb mcpmmenu(}|>)/$MCPmMenu/gsm;
    $mycenter_template =~ s/({|<)yabb mcprofmenu(}|>)/$MCProfMenu/gsm;
    $mycenter_template =~ s/({|<)yabb mcpostsmenu(}|>)/$MCPostsMenu/gsm;
    $mycenter_template =~
      s/({|<)yabb mcglobformstart(}|>)/$MCGlobalFormStart/gsm;
    $mycenter_template =~
s/({|<)yabb mcglobformend(}|>)/ ($MCGlobalFormStart ? "<\/form>" : q{}) /esm;
    #$mycenter_template =~ s/({|<)yabb mcextrasmilies(}|>)/$MCExtraSmilies/gsm;
    $mycenter_template =~ s/({|<)yabb mccontent(}|>)/$MCContent/gsm;
    $mycenter_template =~ s/({|<)yabb mctitle(}|>)/$mctitle/gsm;
    $mycenter_template =~ s/({|<)yabb selecthtml(}|>)/$selecthtml/gsm;
    $mycenter_template =~ s/({|<)yabb forumjump(}|>)//gsm;

	## end new style box
	$yymain .= $mycenter_template;
	if (%usernames_life_quote) { # for display names in Quotes in LivePreview
		$yymain .= q~
<script type="text/javascript">
<!-- //
    ~
          . join(
            q{;},
            map { qq~LivePrevDisplayNames['$_'] = "$usernames_life_quote{$_}"~ }
              keys %usernames_life_quote
          )
          . qq~;
// -->
</script>\n~;
	}
	template();
	return;
}

sub AddFolder {
	if ($iamguest) { fatal_error('im_members_only'); }
	my $storefolders = ${$username}{'PMfolders'};
	my @currStoreFolders = split /\|/xsm, ${$username}{'PMfolders'};
	my $newStoreFolders = 'in|out';

	my $newFolderName = $FORM{'newfolder'};
	chomp $newFolderName;

	my $x = 0;
  NXTFDR: foreach my $currStoreFolder (@currStoreFolders) {
		if ($FORM{'newfolder'}) {
            if ( $newFolderName =~ /[^0-9A-Za-z \-_]/xsm ) {
                fatal_error( 'invalid_character', $inmes_txt{'foldererror'} );
            }
            if ( $FORM{'newfolder'} eq $currStoreFolder ) {
                fatal_error('im_folder_exists');
            }
        }
        elsif ( $FORM{'delfolders'} ) {
            if (   $currStoreFolder ne 'in'
                && $currStoreFolder ne 'out'
                && $FORM{"delfolder$x"} ne 'del' )
            {
				$newStoreFolders .= qq~|$currStoreFolder~;
			}
		}
		$x++;
	}
    if ( $FORM{'newfolder'} ) {
        ${$username}{'PMfolders'} = qq~$storefolders|$FORM{'newfolder'}~;
    }
    elsif ( $FORM{'delfolders'} ) {
        ${$username}{'PMfolders'} = $newStoreFolders;
    }
    buildIMS( $username, 'update' );
	$yySetLocation = qq~$scripturl?action=mycenter~;
	redirectexit();
	return;
}

##  call an unopened message back
sub CallBack {
	if ($iamguest) { fatal_error('im_members_only'); }

	my $receiver = $INFO{'receiver'}; # set variables from GET - localised

    if ( $receiver && $receiver !~ /,/xsm ) {
        $receiver = decloak($receiver);
        if ( CallBackRec( $receiver, $INFO{'rid'}, 1 ) ) {
            fatal_error('im_deleted');
        }
        updateIMS( $receiver, $INFO{'rid'}, 'callback' );
    }
    elsif ($receiver) {
        foreach my $rec ( split /,/xsm, $receiver ) {
            $rec = decloak($rec);
            if ( CallBackRec( $rec, $INFO{'rid'}, 0 ) ) {
                fatal_error('im_deleted_multi');
            }
        }
        foreach my $rec ( split /,/xsm, $receiver ) {
            $rec = decloak($rec);
            CallBackRec( $rec, $INFO{'rid'}, 1 );
            updateIMS( $rec, $INFO{'rid'}, 'callback' );
		}
	}

    updateMessageFlag( $username, $INFO{'rid'}, 'outbox', q{}, 'c' );

	$yySetLocation = qq~$scripturl?action=imoutbox~;
	redirectexit();
    return;
}

sub CallBackRec {
	my ( $receiver, $rid, $do_it ) = @_;

	fopen(RECMSG, "$memberdir/$receiver.msg");
	my @rims = <RECMSG>;
	fclose(RECMSG);

	my ( $nodel, $rmessageid, $fromuser, $flags );
	if ($do_it) { fopen(REVMSG, ">$memberdir/$receiver.msg");}
	## run through and drop the message line
	foreach (@rims) {
		( 
         $rmessageid,$fromuser, undef,  undef, undef,
          undef,      undef,     undef,  undef, undef,
          undef,      undef,     $flags, undef
        ) = split /\|/xsm, $_, 14;
		if (!$do_it) {
			if ($rmessageid == $rid && $fromuser eq $username) {
				if ($flags !~ /u/ism) { $nodel = 1; }
				last;
			}
		}
        else {
			if ( $rmessageid != $rid || $fromuser ne $username ) {
                print REVMSG $_;
            }
			elsif ( $flags !~ /u/ism ) { 
                print REVMSG $_;
                $nodel = 1;
            }
		}
	}
	if ($do_it) { fclose(REVMSG);}
	return $nodel;
}

sub checkIMS { # lookup value in pm file
    my ( $user, $id, $checkfor ) = @_;

	## has the message been opened by the receiver? 1 = yes 0 = no
	if ($checkfor eq 'messageopened') {
		my $messageFoundFlag = checkMessageFlag( $user, $id, 'msg', 'u' );
		if ($messageFoundFlag == 1) { return 0; }
		else {
            $messageFoundFlag = checkMessageFlag( $user, $id, 'imstore', 'u' );
        }
		if ($messageFoundFlag == 1) { return 0; }
		else { return 1; }

	## has the message been replied to? 1 = yes 0 = no
	}
    elsif ($checkfor eq 'messagereplied') {
		## check in msg and imstore
		my $messageFoundFlag = checkMessageFlag($user, $id, 'msg', 'r');
		if ($messageFoundFlag == 1) { return 1; }
		else {
            $messageFoundFlag = checkMessageFlag($user, $id, 'imstore', 'r');
        }
		if ($messageFoundFlag == 1) { return 1; }
		else { return 0; }
	}
    return;
}

sub checkMessageFlag {
 # look for $user.$pmFile, find $id message and check for $messageFlag
	my ($user, $id, $pmFile, $messageFlag) = @_;
	my $messageFoundFlag = 0;
	if ( %{ 'MF' . $user . $pmFile} ) {
		if ( exists ${'MF' . $user . $pmFile}{$id}
           && ${ 'MF' . $user . $pmFile}{$id} =~ /$messageFlag/ism )
        {
           $messageFoundFlag = 1;
        }
	}
    elsif (-e "$memberdir/$user.$pmFile") {
		fopen (USERMSG, "$memberdir/$user.$pmFile");
		my @userMessages = <USERMSG>;
		fclose (USERMSG);
		my ($uMessageId,$uMessageFlags);
		foreach (@userMessages) {
            (
                $uMessageId, undef, undef,          undef, undef,
                undef,       undef, undef,          undef, undef,
                undef,       undef, $uMessageFlags, undef
            ) = split /\|/xsm, $_, 14;
			${'MF' . $user . $pmFile}{$uMessageId} = $uMessageFlags;
			if ( $uMessageId == $id && $uMessageFlags =~ /$messageFlag/ism ) {
                $messageFoundFlag = 1;
            }
		}
	}
	return $messageFoundFlag;
}

sub updateMessageFlag {
 # look for $user.$pmFile, find $id message and check for $messageFlag. change to $newMessageFlag
	my ($user, $id, $pmFile, $messageFlag, $newMessageFlag) = @_;
	my $messageFoundFlag = 0;
	if (
        (
            !exists ${'MF' . $user . $pmFile}{$id}
            || ( $messageFlag ne q{}
                && ${ 'MF' . $user . $pmFile}{$id} =~ /$messageFlag/xsm )
            || ( $messageFlag eq q{}
                && !${'MF' . $user . $pmFile}{$id} =~ /$newMessageFlag/xsm )
        )
        && -e "$memberdir/$user.$pmFile"
      )
    {
		fopen ("USERFILE", "+<$memberdir/$user.$pmFile");
		my @userFile = <USERFILE>;
		seek USERFILE, 0, 0;
		truncate USERFILE, 0;
		foreach my $userMessage (@userFile) {
			my (
                 $uMessageId, $uFrom, $uToUser, $uTocc,
                 $uTobcc, $uSubject, $uDate, $uMessage,
                 $uPid, $uReply , $uip, $uStatus,
                 $uMessageFlags, $uStorefolder, $uAttach
            ) = split /\|/xsm, $userMessage;
			if ($uMessageId == $id) {
                if ( $newMessageFlag ne q{} ) { $uMessageFlags =~ s/$newMessageFlag//gism;}
                if ( $uMessageFlags =~ s/$messageFlag/$newMessageFlag/ixsm ) {
					$messageFoundFlag = 1;
                }
                else {
					$uMessageFlags .= $newMessageFlag;
				}
				$userMessage =
"$uMessageId|$uFrom|$uToUser|$uTocc|$uTobcc|$uSubject|$uDate|$uMessage|$uPid|$uReply|$uip|$uStatus|$uMessageFlags|$uStorefolder|$uAttach";
			}
			${'MF' . $user . $pmFile}{$uMessageId} = $uMessageFlags;
			print {USERFILE}  $userMessage;
		}
		fclose(USERFILE);
	}
	return $messageFoundFlag;
}

sub updateIMS {
 # update .ims file for user: &updateIMS(<user>,<PM msgid>,[target/action])
	my ($user,$id,$target) = @_;

	# load the user who is processed here, if not allready loaded
    if ( !exists ${$user}{'PMmnum'} ) { buildIMS( $user, 'load' ); }

	# new msg received - add to the inbox lists and increment the counts
	if ($target eq 'messagein') {
		# read the lines into temp variables
		${$user}{'PMmnum'}++;
		${$user}{'PMimnewcount'}++;

	# message sent - add to the outbox list and increment count
	}
    elsif ($target eq 'messageout') {
		${$user}{'PMmoutnum'}++;

	# reading msg in inbox - newcount -1, remove from unread list
	}
    elsif ($target eq 'inread') {
		if ( updateMessageFlag($user, $id, 'msg', 'u', q{} ) ) {
            ${$user}{'PMimnewcount'}--;
        }
		else { return; }

	# callback message - take off imnewcount, mnum
	}
    elsif ($target eq 'callback') {
		${$user}{'PMmnum'}--;
		${$user}{'PMimnewcount'}--;

	# draft added
	}
    elsif ($target eq 'draftadd') {
		${$user}{'PMdraftnum'}++;

	# draft send
	}
    elsif ($target eq 'draftsend') {
		${$user}{'PMdraftnum'}--;
	}

	buildIMS( $user, 'update' ); # rebuild the .ims file it with the new values
    return;
}

# delete|move IMs
sub Del_Some_IM {
	LoadLanguage('InstantMessage');
	if ($iamguest) { fatal_error('im_members_only'); }

	my $fileToOpen = "$username.msg";
	if ($INFO{'caller'} == 2)    { $fileToOpen = "$username.outbox"; }
	elsif ($INFO{'caller'} == 3) { $fileToOpen = "$username.imstore"; }
	elsif ($INFO{'caller'} == 4) { $fileToOpen = "$username.imdraft"; }
	elsif ($INFO{'caller'} == 5) { $fileToOpen = 'broadcast.messages'; }

	fopen(USRFILE, "+<$memberdir/$fileToOpen");
	seek USRFILE, 0, 0;
	my @messages = <USRFILE>;
	seek USRFILE, 0, 0;
	truncate USRFILE, 0;

	# deleting
	if (  $FORM{'imaction'} eq $inmes_txt{'remove'}
       || $INFO{'action'} eq $inmes_txt{'remove'}
       || $INFO{'deleteid'} )
    {
		my %CountStore;
		if ( $INFO{'caller'} == 2 )    { ${$username}{'PMmoutnum'} = 0; }
		elsif ( $INFO{'caller'} == 4 ) { ${$username}{'PMdraftnum'} = 0; }
		elsif ( $INFO{'caller'} != 3 && $INFO{'caller'} != 5) {
            ${$username}{'PMmnum'} = 0;
            ${$username}{'PMimnewcount'} = 0;
        }

		if ( $INFO{'deleteid'}) {
            $FORM{'message' . $INFO{'deleteid'}} = 1;
        } # single delete

		foreach (@messages) {
			my @m = split /\|/xsm, $_;
			if ( !exists $FORM{'message' . $m[0] } ) {
				print {USRFILE} $_;

				if ($INFO{'caller'} == 2)    { ${$username}{'PMmoutnum'}++; }
				elsif ($INFO{'caller'} == 3) { $CountStore{$m[13]}++; }
				elsif ($INFO{'caller'} == 4) { ${$username}{'PMdraftnum'}++; }
				elsif ($INFO{'caller'} != 5) {
                    ${$username}{'PMmnum'}++;
                    if ( $m[12] =~ /u/sm ) { ${$username}{'PMimnewcount'}++; }
                }
            }
            else {
				if ($INFO{'caller'} == 3) {
					$INFO{'viewfolder'} = $m[13];
				}
                elsif ($INFO{'caller'} == 5) {
					if ( ${$username}{'PMbcRead'} !~ s/\b$m[0]$//gsm) { 
                        ${$username}{'PMbcRead'} =~ s/$m[0]\b//gsm ;
                    }
				}
			}
		}
		fclose(USRFILE);
		if ($INFO{'caller'} == 3) {
            ${$username}{'PMfoldersCount'} = q{};
			${$username}{'PMstorenum'} = 0;
            foreach ( split /\|/xsm, ${$username}{'PMfolders'} ) {
				$CountStore{$_} ||= 0;
				${$username}{'PMfoldersCount'} .=
                  ${$username}{'PMfoldersCount'} eq q{}
                  ? $CountStore{$_}
                  : "|$CountStore{$_}";
				${$username}{'PMstorenum'} += $CountStore{$_};
			}
		}
		buildIMS($username, 'update');

	#  moving messages
	}
    elsif ($FORM{'imaction'} eq $inmes_imtxt{'store'}
        || $INFO{'imaction'} eq $inmes_imtxt{'store'})
   {
		my (@newmessages,%CountStore,$imstorefolder);
		if ( $FORM{'tostorefolder'} ) {
            $imstorefolder = $FORM{'tostorefolder'};
        }
		elsif ($INFO{'caller'} == 1) { $imstorefolder = 'in'; }
		else { $imstorefolder = 'out'; }

		foreach (@messages) {
            if ( !$FORM{ 'message' . ( split /\|/xsm, $_, 2 )[0] } ) {
				if ($INFO{'caller'} != 3) {
					print {USRFILE} $_;
				}
                else {
                    my @m = split /\|/xsm, $_;
                    push @newmessages, [@m];
					$CountStore{$m[13]}++;
				}
			}
            else {
                my @m = split /\|/xsm, $_;
				$m[13] = $imstorefolder;
                push @newmessages, [@m];
				$CountStore{$imstorefolder}++;
				if ($INFO{'caller'} != 3) {
					${$username}{'PMstorenum'}++;
					if ($INFO{'caller'} == 1) { ${$username}{'PMmnum'}--; }
					elsif ($INFO{'caller'} == 2) {
                        ${$username}{'PMmoutnum'}--;
                    }
                    if ( $m[12] =~ /u/sm ) { ${$username}{'PMimnewcount'}--; }
				}
			}
		}
		fclose(USRFILE);

		if (@newmessages) {
			if ($INFO{'caller'} != 3) {
				fopen(IUSRFILE, "$memberdir/$username.imstore");
				foreach (<IUSRFILE>) {
					my @m = split /\|/xsm, $_;
					push @newmessages, [@m];
					$CountStore{$m[13]}++;
				}
				fclose(IUSRFILE);
			}
			fopen(TRANSFER, ">$memberdir/$username.imstore");
			print {TRANSFER} 
               map({ join(q{|}, @{$_}) }
                 reverse sort { ${$a}[6] <=> ${$b}[6] } @newmessages
            );
			fclose(TRANSFER);

			${$username}{'PMfoldersCount'} = q{};
			foreach (split /\|/xsm, ${$username}{'PMfolders'} ) {
				$CountStore{$_} ||= 0;
				${$username}{'PMfoldersCount'} .=
                  ${$username}{'PMfoldersCount'} eq q{}
                  ? $CountStore{$_}
                  : "|$CountStore{$_}";
			}
			buildIMS($username, 'update');
		}
	}

	my $redirect = 'im';
	if ($INFO{'caller'} == 2)    { $redirect = 'imoutbox'; }
	elsif ($INFO{'caller'} == 3) {
        $redirect = "imstorage;viewfolder=$INFO{'viewfolder'}";
    }
	elsif ($INFO{'caller'} == 4) { $redirect = 'imdraft'; }
	elsif ($INFO{'caller'} == 5) { $redirectview = ';focus=bmess'; }

	$yySetLocation = qq~$scripturl?action=$redirect~;
    redirectexit();
    return;
}

# if the user is valid.
sub LoadValidUserDisplay {
	my ($muser) = @_;
	if ( !$yyUDLoaded{$muser} && -e "$memberdir/$muser.vars" ) {
        $sm = 1;
        LoadUserDisplay($muser);
    }
    return;
}

# create either a full link or just a name for the IM display
sub CreateUserDisplayLine {
    my ($usrname) = @_;
	my $usernamelink;

    $sendPM     = q{};
    $sendEmail  = q{};
    $membAdInfo = q{};

	if ($yyUDLoaded{$usrname}) {
        if (
            $INFO{'caller'} != 2
            || (   $mstatus !~ /b/sm
                && $mtousers !~ /,/xsm
                && !$mccusers
                && !$mbccusers )
          )
        {
			$signature = ${$uid.$usrname}{'signature'};
			if ( $INFO{'caller'} == 2 || $INFO{'caller'} == 3) {
                $signature = q{};
            }
            if ( $INFO{'caller'} != 5 || ( $mstatus ne 'g' && $mstatus ne 'ga' ) ) {
                   userOnLineStatus($usrname);
            }

			if (!$iamguest) {
				# Allow instant message sending if current user is a member.
				$sendPM =
qq~$menusep<a href="$scripturl?action=imsend;to=$useraccount{$usrname}">$img{'message_sm'}</a>~;
			}
			if (!${$uid.$usrname}{'hidemail'}
                || $iamadmin
                || $iamgmod
                || $allow_hide_email != 1)
            {
				$sendEmail =
qq~$menusep<a href="mailto:${$uid.$usrname}{'email'}">$img{'email_sm'}</a>~;
			}

            if (!$minlinkweb) { $minlinkweb = 0; }
            $membAdInfo .=
              ${ $uid . $usrname }{'weburl'}
              ? $menusep . ${ $uid . $usrname }{'weburl'}
              : q{};
            $membAdInfo .=
              ${ $uid . $usrname }{'gtalk'}
              ? $menusep . ${ $uid . $usrname }{'gtalk'}
              : q{};
            $membAdInfo .=
              ${ $uid . $usrname }{'skype'}
              ? $menusep . ${ $uid . $usrname }{'skype'}
              : q{};
            $membAdInfo .=
              ${ $uid . $usrname }{'myspace'}
              ? $menusep . ${ $uid . $usrname }{'myspace'}
              : q{};
            $membAdInfo .=
              ${ $uid . $usrname }{'facebook'}
              ? $menusep . ${ $uid . $usrname }{'facebook'}
              : q{};
            $membAdInfo .=
              ${ $uid . $usrname }{'icq'}
              ? $menusep . ${ $uid . $usrname }{'icq'}
              : q{};
            $membAdInfo .=
              ${ $uid . $usrname }{'yim'}
              ? $menusep . ${ $uid . $usrname }{'yim'}
              : q{};
            $membAdInfo .=
              ${ $uid . $usrname }{'aim'}
              ? $menusep . ${ $uid . $usrname }{'aim'}
              : q{};
		}
		$usernamelink = $link{$usrname};
		if ($musername eq $username) {
			$imOpened = checkIMS($usrname, $messageid, 'messageopened');
			LoadUser($usrname);
			if (
                !$imOpened
                && (${$uid.$usrname}{'notify_me'} < 2
                || $enable_notifications < 2)
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
sub IMPost {
	if (($INFO{'bmess'} || $FORM{'isBMess'}) eq 'yes') { $sendBMess = 1; }
	##  if user is not a FA/gmod and has a postcount below the threshold
	if (!$staff && ${$uid.$username}{'postcount'} < $numposts) {
		fatal_error('im_low_postcount');
	}
	##  guests not allowed
	if ($iamguest) { fatal_error('im_members_only'); }
	my ($mdate, $mip, $mmessage);
	##  if the IM has a number assigned already, open the right IM file
	if ($INFO{'id'} ne q{} && !$replyguest) {
		if ($INFO{'caller'} < 5) {
           updateIMS($username, $INFO{'id'}, 'inread');
        }

		my $pmFileType = "$username.msg";
		if ($INFO{'caller'} == 2) { $pmFileType = "$username.outbox"; }
		elsif ($INFO{'caller'} == 3) { $pmFileType = "$username.imstore"; }
		elsif ($INFO{'caller'} == 4) { $pmFileType = "$username.imdraft"; }
		elsif ($INFO{'caller'} == 5) { $pmFileType = 'broadcast.messages'; }


		fopen(FILE, "$memberdir/$pmFileType");
		@messages = <FILE>;
		fclose(FILE);
		## split content of IM file up
		foreach my $checkTheMessage (@messages) {
            (
                $qmessageid, $mfrom,   $mto,     $mtocc,  $mtobcc,
                $msubject,   $mdate,   $message, $mparid, $mreplyno,
                $mip,        $mstatus, $mflags,  $mstore, $mattach
            ) = split /\|/xsm, $checkTheMessage;
			if ($qmessageid == $INFO{'id'}) { last; }
		}
		## remove 're:' from subject (why?)
        $msubject =~ s/Re: //gsm;
		## if replying/quoting, up the reply# by 1
		if ($INFO{'quote'} || $INFO{'reply'}) {
           $mreplyno++;
           $INFO{'status'} = $mstatus;
        }
		##  if quote
		if ($INFO{'reply'}) { $message = q{}; }
		if ($INFO{'quote'}) {
			# swap out brs and spaces
            $message =~ s/<br.*?>/\n/gism;
            $message =~ s/ \&nbsp; \&nbsp; \&nbsp;/\t/igsm;
			if (!$nestedquotes) {
				$message =~ 
s/\n{0,1}\[quote([^\]]*)\](.*?)\[\/quote([^\]]*)\]\n{0,1}/\n/isgm;
			}
			if ($mfrom ne q{} && $do_scramble_id) {
               $cloakedAuthor = cloak($mfrom);
            }
			else { $cloakedAuthor = $mfrom; }

			# next 2 lines for display names in Quotes in LivePreview
			LoadUser($mfrom);
			$usernames_life_quote{$cloakedAuthor} =
              ${$uid.$mfrom}{'realname'};

			$quotestart =
              int($quotemsg / $maxmessagedisplay) * $maxmessagedisplay;
			if ($INFO{'forward'} || $INFO{'quote'}) {
				$message =
qq~[quote author=$cloakedAuthor link=impost date=$mdate\]$message\[/quote\]\n~;
			}
			if ($message =~ /\#nosmileys/isgm) {
                $message =~ s/\#nosmileys//isgm;
                $nscheck = 'checked';
            }
		}
		if ($INFO{'reply'} || $INFO{'forward'} || $INFO{'quote'} ) {
            $msubject = "Re: $msubject";
        }
	}
     elsif ($replyguest) {
		fopen(FILE, "$memberdir/broadcast.messages");
		my @messages = <FILE>;
		fclose(FILE);
		## split content of IM file up
		foreach my $checkTheMessage (@messages)
       {
            (
                $qmessageid, $mfrom,   $mto,     $mtocc,  $mtobcc,
                $msubject,   $mdate,   $message, $mparid, $mreplyno,
                $mip,        $mstatus, $mflags,  $mstore, $mattach
            ) = split /\|/xsm, $checkTheMessage;
			if ($qmessageid == $INFO{'id'}) { last; }
		}
		($guestName, $guestEmail) = split /\ /sm, $mfrom;
		$guestName =~ s/%20/ /gsm;
        $message   =~ s/<br.*?>/\n/gism;
		$message =~ s/ \&nbsp; \&nbsp; \&nbsp;/\t/igsm;
        $message   =~ s/\[b\](.*?)\[\/b\]/*$1*/isgm;
        $message   =~ s/\[i\](.*?)\[\/i\]/\/$1\//isgm;
        $message   =~ s/\[u\](.*?)\[\/u\]/_$1_/isgm;
        $message   =~ s/\[.*?\]//gsm;
		my $sendtouser = ${$uid.$username}{'realname'};
		$mdate = timeformat( $mdate, 1 );
		require "$sourcedir/Mailer.pl";
		LoadLanguage('Email');

		#sender email date subject message
		$message = template_email(
            $replyguestmail,
            {
                'sender' => $guestName,
                'email' => $guestEmail,
                'sendto' => $sendtouser,
                'date' => $mdate,
                'subject' => $msubject,
                'message' => $message
            }
        );
		$msubject = qq~Re: $msubject~;
	}

    if ( $INFO{'forward'} || $INFO{'quote'} ) { FromHTML($message); }
	FromHTML($msubject);

	$submittxt = $inmes_txt{'sendmess'};
	if ($INFO{'forward'} == 1) { $submittxt = $inmes_txt{'forward'}; }
	$destination = 'imsend2';
	$waction = 'imsend';
	$is_preview = 0;
	$post = 'imsend';
	$previewtxt = $inmes_txt{'507'};
	$preview = 'previewim';
	$icon = 'xx';
	$draft = 'draft';
	$mctitle = $inmes_txt{'sendmess'};
	if ($sendBMess) { $mctitle = $inmes_txt{'sendbroadmess'}; }
    return;
}

sub MarkAll {
	if ($iamguest) { fatal_error('im_members_only'); }

	fopen(FILE, "+<$memberdir/$username.msg");
	seek FILE, 0, 0;
	my @messages = <FILE>;
	seek FILE, 0, 0;
	truncate FILE, 0;
	foreach (@messages) {
		my (
            $imessageid,     $imusername,      $imusernameto,
            $imusernametocc, $imusernametobcc, $imsub,
            $imdate,         $mmessage,        $imessagepid,
            $imreply,        $mip,             $imstatus,
            $imflags,        $imstore,         $imattach
        ) = split /\|/xsm, $_;
		if ($imflags =~ s/u//ism) {
			print {FILE} "$imessageid|$imusername|$imusernameto|$imusernametocc|$imusernametobcc|$imsub|$imdate|$mmessage|$imessagepid|$imreply|$mip|$imstatus|$imflags|$imstore|$imattach";
		}
        else { print {FILE} $_; }
	}
	fclose(FILE);

	${$username}{'PMimnewcount'} = 0;
	buildIMS($username, 'update');

	if ($INFO{'oldmarkread'}) {
		$yySetLocation = qq~$scripturl?action=im~;
		redirectexit();
	}
	$elenable = 0;
    croak q{};    # This is here only to avoid server error log entries!
}

# change type of page index for PM
sub PmPageindex {
	my ( $msindx, $trindx, $mbindx, undef ) =
      split /\|/xsm, ${$uid.$username}{'pageindex'};
	if ($INFO{'action'} eq 'pmpagedrop') {
        ${$uid.$username}{'pageindex'} = qq~$msindx|$trindx|$mbindx|1~;
    }
	if ($INFO{'action'} eq 'pmpagetext') {
        ${$uid.$username}{'pageindex'} = qq~$msindx|$trindx|$mbindx|0~;
    }
	UserAccount($username, 'update');
	if ($INFO{'pmaction'} =~ /\//xsm) {
        my ( $act, $val ) = split /\//xsm, $INFO{'pmaction'};
		$INFO{'pmaction'} = $act . ';start=' . $val;
	}
	if ($INFO{'focus'} eq 'bmess') { $bmesslink = q~;focus=bmess~;}
	$yySetLocation =
      qq~$scripturl?action=$INFO{'pmaction'}$bmesslink;start=$INFO{'start'}~
      . ($INFO{'viewfolder'} ? ";viewfolder=$INFO{'viewfolder'}" : q{} );
	redirectexit();
    return;
}

# draw the whole block , with the menu, and the various PM views.
sub drawPMbox {
    my ($PMfileToOpen) = @_;
	LoadLanguage('InstantMessage');
	LoadLanguage('Profile');
#	@dimmessages;
#	@bmessages;
	if (
         ( $PMfileToOpen || $INFO{'focus'} )
        && $view eq 'pm'
          && (    $PM_level == 1
               || ( $PM_level  == 2 && $staff )
            || ( $PM_level == 3 && ( $iamadmin || $iamgmod ) ) )
      )
   {
#		( $qmessageid, $mfrom, $mto, $mtocc, $mtobcc, $msubject, $mdate, $message, $mparid, $mreplyno, $mip, $mstatus, $mflags, $mstore, $mattach);

		if (!$INFO{'focus'}) {
			if ($callerid < 5) {
				fopen(NFILE, "$memberdir/$username.$PMfileToOpen");
				@dimmessages = <NFILE>;
				my ($mID,$mFlag);
				foreach ( reverse @dimmessages ) {
					(
                         $mID, undef, undef, undef, undef, undef, undef,
                         undef, undef, undef, undef, undef, $mFlag, undef
                    ) = split /\|/xsm, $_,  14;
					${$username . $PMfileToOpen}{$mID} = $mFlag;
					if ($INFO{'id'} == -1 && $mFlag eq 'u') {
						$INFO{'id'} = $mID;
					}
				}
			}
            else {
				fopen(NFILE, "$memberdir/broadcast.messages");
				@bmessages = <NFILE>;
			}
			fclose(NFILE);
		}
		elsif ($INFO{'focus'} eq 'bmess' && $PMenableBm_level > 0) {
			fopen(BFILE, "$memberdir/broadcast.messages");
			@bmessages = <BFILE>;
			fclose(BFILE);
		}
		$stkmess = 0;
		if (@bmessages > 0) {
			foreach my $checkbcm (@bmessages) {
                my (
                    undef, $mfrom,      $mto,  undef, undef,
                    undef, undef,       undef, undef, undef,
                    undef, $messStatus, undef
                ) = split /\|/xsm, $checkbcm;
				if ($mfrom eq $username || BroadMessageView($mto)) {
					if ( $INFO{'sort'} ne 'gpdate'
                        && ( $messStatus =~ m/g/sm || $messStatus =~ m/a/sm ) )
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
        @stkbmessages = reverse sort { $a <=> $b } @stkbmessages;
        @tmpbmessages = reverse sort { $a <=> $b } @tmpbmessages;
        push @dimmessages, @stkbmessages;
        push @dimmessages, @tmpbmessages;
		undef @stkbmessages;
		undef @tmpbmessages;
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
<!--
var postas = '$post';
function checkForm(theForm) {
	if (navigator.appName == "Microsoft Internet Explorer" && document.getElementById('iecopy').checked == true) { theForm.message.createTextRange().execCommand("Copy"); }
	if (theForm.subject.value == "") { alert("$post_txt{'77'}"); theForm.subject.focus(); return false }
	~ . (
        $iamguest && $post ne 'imsend'
        ? qq~if (theForm.name.value == "" || theForm.name.value == "_" || theForm.name.value == " ") { alert("$post_txt{'75'}"); theForm.name.focus(); return false }
	if (theForm.name.value.length > 25)  { alert("$post_txt{'568'}"); theForm.name.focus(); return false }
	if (theForm.email.value == "") { alert("$post_txt{'76'}"); theForm.email.focus(); return false }
	if (! checkMailaddr(theForm.email.value)) { alert("$post_txt{'500'}"); theForm.email.focus(); return false }
~ 
        : qq~if (postas == "imsend") { if (theForm.toshow.value == "") { alert("$post_txt{'752'}"); theForm.toshow.focus(); return false } }~
      )
      . qq~
	if (theForm.message.value == "") { alert("$post_txt{'78'}"); theForm.message.focus(); return false }
	return true
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
//-->
</script>
	~;

	if (
            $action =~ /^im/sm
       && (!@dimmessages && $INFO{'focus'} ne 'bmess')
       && ($PM_level == 1
            || ( $PM_level == 2 && $staff )
            || ( $PM_level == 3 && ( $iamadmin || $iamgmod ) ) )
      )
    {
		if (!@dimmessages) {
			if ( $action eq 'im' ) { 
                unlink("$memberdir/$username.msg");
            }
			elsif ($action eq 'imoutbox')  {
                unlink("$memberdir/$username.outbox");
            }
			elsif ($action eq 'imstorage') {
                unlink("$memberdir/$username.imstore");
            }
			elsif ($action eq 'imdraft') {
                unlink("$memberdir/$username.imdraft");
            }
		}
	}

    LoadCensorList();

	# Fix moderator showing in info
	$sender = 'im';
	$acount = 0;
	## set browser title
	$yytitle = $mycenter_txt{'welcometxt'};

	## start new container - left side is menu, right side is content
	my ($display_prof, $display_posts, $display_pm, $tabPMHighlighted,
        $tabProfHighlighted, $tabNotifyHighlighted );

	if ( $mycenter_template =~ /({|<)yabb mcmenu(}|>)/gsm ) {
		mcMenu();
		$newtemplate = 1;
	}

    if (
        $view eq 'profile'
        || (
            $view eq 'mycenter'
            && (   $PM_level == 0
                || ( $PM_level == 2 && !$staff )
                || ( $PM_level == 3 && !$iamadmin && !$iamgmod ) )
        )
      )
    {
		$display_prof = 'inline';
		$tabProfHighlighted = 'windowbg2';
	}
    else {
		$display_prof = 'none';
		$tabProfHighlighted = 'windowbg';
	}

	if ($view eq 'notify' || $view eq 'favorites' || $view eq 'recentposts') {
		$display_posts = 'inline';
		$tabNotifyHighlighted = 'windowbg2';
	}
    else {
		$display_posts = 'none';
		$tabNotifyHighlighted = 'windowbg';
	}

    if (
        $view eq 'pm'
        || (
            $view eq 'mycenter'
            && (   $PM_level == 1
                || ( $PM_level == 2 && $staff )
                || ( $PM_level == 3 && ( $iamadmin || $iamgmod ) ) )
        )
      )
    {
		$display_pm = 'inline';

		$tabPMHighlighted = 'windowbg2';
	}
    else {
		$display_pm = 'none';
		$tabPMHighlighted = 'windowbg';
	}

	my $tabWidth = '33%';
	if (    $PM_level == 0
        || ( $PM_level == 2 && !$staff )
        || ( $PM_level == 3 && !$iamadmin && !$iamgmod) )
    {
        $tabWidth = '50%';
    }
    $MCViewMenu     = q{};
    $MCPmMenu       = q{};
    $MCProfMenu     = q{};
    $MCPostsMenu    = q{};
    $MCExtraSmilies = q{};
    $MCContent      = q{};

	if ($newtemplate) {
		$MCViewMenu .= q~
		<script type="text/javascript">
		<!--
		function changeToTab(tab) {~;
        if (   $PM_level == 1
            || ( $PM_level == 2 && $staff )
            || ( $PM_level == 3 && ( $iamadmin || $iamgmod ) ) )
        {
            $MCViewMenu .= q~
			document.getElementById('cont_pm').style.display = 'none';
			document.getElementById('menu_pm').className = '';~;
		}
		$MCViewMenu .= q~
			document.getElementById('cont_prof').style.display = 'none';
			document.getElementById('menu_prof').className = '';
			document.getElementById('cont_posts').style.display = 'none';
			document.getElementById('menu_posts').className = '';
			document.getElementById('cont_' + tab).style.display = 'inline';
			document.getElementById('menu_' + tab).className = 'selected';
		}
		//-->
		</script>~;
	}
    else {
		$MCViewMenu .= q~
		<script type="text/javascript">
		<!--
		function changeToTab(tab) {~;
        if (   $PM_level == 1
            || ( $PM_level == 2 && $staff )
            || ( $PM_level == 3 && ( $iamadmin || $iamgmod ) ) )
        {
            $MCViewMenu .= q~
			document.getElementById('cont_pm').style.display = 'none';
			document.getElementById('menu_pm').className = 'windowbg';~;
		}
		$MCViewMenu .= qq~
			document.getElementById('cont_prof').style.display = 'none';
			document.getElementById('menu_prof').className = 'windowbg';
			document.getElementById('cont_posts').style.display = 'none';
			document.getElementById('menu_posts').className = 'windowbg';
			document.getElementById('cont_' + tab).style.display = 'inline';
			document.getElementById('menu_' + tab).className = 'windowbg2';
		}
		//-->
		</script>\n~;
		$MCViewMenu .= q~
		<table>
		<tr>~;
        if (   $PM_level == 0
            || ( $PM_level == 2 && !$staff )
            || ( $PM_level == 3 && !$iamadmin && !$iamgmod ) )
        {
			$display_prof = 'inline';
			$tabProfHighlighted = 'windowbg2';
		}
        if (   $PM_level == 1
            || ( $PM_level == 2 && $staff )
            || ( $PM_level == 3 && ( $iamadmin || $iamgmod ) ) )
        {
			$MCViewMenu .= qq~
			<td style="width:$tabWidth" class="$tabPMHighlighted center vtop" id="menu_pm"><a href="javascript:void(0);" onclick="changeToTab('pm'); return false;">$mc_menus{'messages'}</a></td>~;
		}
		$MCViewMenu .= qq~
			<td style="width:$tabWidth" class="$tabProfHighlighted center" id="menu_prof"><a href="javascript:void(0);" onclick="changeToTab('prof'); return false;">$mc_menus{'profile'}</a></td>
			<td style="width:$tabWidth" class="$tabNotifyHighlighted center" id="menu_posts"><a href="javascript:void(0);" onclick="changeToTab('posts'); return false;">$mc_menus{'posts'}</a></td>
		</tr>
		</table>\n~;
	}

## start Profile div
	$MCProfMenu = qq~
	<div id="cont_prof" style="display: $display_prof">
	<table id="prof" class="windowbg2 pad_4px">
		<tr>
			<td>~;

	## links for profile pages. SID is now cloaked and controls whether or not
	## the action goes to authenticate or straight to the page.
	## The trick is to use $page to pass the intended page through and switch over on
	## positive id.
	if ($page && $page ne $action)  { $action = $page; }
	my $profileLink;
	my $sid = $INFO{'sid'};
    my $thisLink = q{};
    my $sidLink  = q{};
	if (!$sid) {$sid = $FORM{'sid'}; }
	if ($sid) { $sidLink = ";sid=$sid"; }

	if (!$sid) { $profileLink = 'action=profileCheck;page='; }
	else {$profileLink = 'action=';}
	$thisLink = 'action=myviewprofile;username=' . $useraccount{$username};
	$MCProfMenu .= qq~
	<span class="nav bold"><a href="$scripturl?$thisLink">$inmes_txt{'viewprofile'}</a></span><br /><br />~;

	$thisLink =
      $profileLink . 'myprofile;username=' . $useraccount{$username} . $sidLink;
	$MCProfMenu .= qq~
	<span class="nav bold"><a href="$scripturl?$thisLink">$profile_txt{'79'}</a></span><br />~;

	$thisLink =
        $profileLink
      . 'myprofileContacts;username='
      . $useraccount{$username}
      . $sidLink;
	$MCProfMenu .= qq~
	<span class="nav bold"><a href="$scripturl?$thisLink">$profile_txt{'819'}</a></span><br />~;

	$thisLink =
        $profileLink
      . 'myprofileOptions;username='
      . $useraccount{$username}
      . $sidLink;
	$MCProfMenu .= qq~
	<span class="nav bold"><a href="$scripturl?$thisLink">$profile_txt{'818'}</a></span><br />~;

	if ($buddyListEnabled) {
		$thisLink =
            $profileLink
          . 'myprofileBuddy;username='
          . $useraccount{$username}
          . $sidLink;
		$MCProfMenu .= qq~
		<span class="nav bold"><a href="$scripturl?$thisLink">$profile_buddy_list{'buddylist'}</a></span><br />~;
	}

    if (   $PM_level == 1
        || ( $PM_level == 2 && $staff )
        || ( $PM_level == 3 && ( $iamadmin || $iamgmod ) ) )
    {
		$thisLink =
            $profileLink
          . 'myprofileIM;username='
          . $useraccount{$username}
          . $sidLink;
		$MCProfMenu .= qq~
		<span class="nav bold"><a href="$scripturl?$thisLink">$inmes_txt{'765'}</a></span>
		<br />
		~;
	}

    if (
        $iamadmin
        || (   $iamgmod
            && $allow_gmod_profile
            && $gmod_access2{'profileAdmin'} eq 'on' )
      )
    {
		$thisLink =
            $profileLink
          . 'myprofileAdmin;username='
          . $useraccount{$username}
          . $sidLink;
		$MCProfMenu .= qq~
			<span class="nav bold"><a href="$scripturl?$thisLink">$profile_txt{'820'}</a></span>
			<br />
		~;
	}

	$MCProfMenu .= q~
		</td></tr>
	</table>
	</div>
	~;
## end Profile div

## start Posts div
	$MCPostsMenu = qq~
	<div id="cont_posts" style="display: $display_posts">
	<table id="posts" class="windowbg2 center pad_4px">
		<tr>
			<td class="windowbg2">
				<span class="nav bold"><a href="$scripturl?action=shownotify">$inmes_txt{'viewnotify'}</a></span><br />
				<span class="nav bold"><a href="$scripturl?action=favorites">$inmes_txt{'viewfavs'}</a></span><br />
	~;
	if (${$uid.$username}{'postcount'} > 0 && $maxrecentdisplay > 0) {
		$MCPostsMenu .= qq~
		<br /><br />
		<form action="$scripturl?action=myusersrecentposts;username=$useraccount{$username}" method="post" style="display: inline;">
		<span class="small">$inmes_txt{'viewrecentposts'} <select name="viewscount" size="1">~;

		my ($x,$y) = (int($maxrecentdisplay/5),0);
		if ($x) {
            foreach my $i ( 1 .. 5 ) {
				$y = $i * $x;
				$MCPostsMenu .= qq~
			<option value="$y">$y</option>~;
			}
		}
        if ( $maxrecentdisplay > $y ) {
		$MCPostsMenu .= qq~
        <option value="$maxrecentdisplay">$maxrecentdisplay</option>~
              ;
        }

		$MCPostsMenu .= qq~
		</select> $inmes_txt{'viewrecentposts2'}
		<input type="submit" value="$inmes_txt{'goviewrecent'}" class="button" /></span>
		</form>
	~;
	}
	$MCPostsMenu .= q~
		</td></tr>
	</table>
	</div>
	~;
## end Posts div

	if (!$replyguest) {
		if ($view eq 'pm' && $action ne 'imsend' && $action ne 'imsend2') {
			my $imstoreFolder;
			if ( $action eq 'imstorage' ) {
               $imstoreFolder = ";viewfolder=$INFO{'viewfolder'}";
            }
			$MCGlobalFormStart .= qq~
			<form action="$scripturl?action=deletemultimessages;caller=$callerid$imstoreFolder" method="post" name="searchform" enctype="application/x-www-form-urlencoded" accept-charset="$yycharset">
			~;

		}
        elsif ($view eq 'pm') {
			$MCGlobalFormStart .=
qq~<form action="$scripturl?action=$destination" method="post" name="postmodify" id="postmodify" enctype="application/x-www-form-urlencoded" onsubmit="~;
			if ( !${$uid.$toshow}{'realname'} ) {
                $MCGlobalFormStart .= qq~selectNames(); ~;
            }
			$MCGlobalFormStart .=
q~if(!checkForm(this)) { return false; } else { return submitproc(); }">~;

			## add smilies box
			## smilies
			$MCPmMenu .= qq~
		<script src="$yyhtml_root/ubbc.js" type="text/javascript"></script>
		<script type="text/javascript">
		<!--~;

			if ( $smiliestyle == 1 ) {
                $smiliewinlink = qq~$scripturl?action=smilieput~;
            }
			else { $smiliewinlink = qq~$scripturl?action=smilieindex~; }

			$MCPmMenu .= qq~
		function smiliewin() {
			window.open("$smiliewinlink", 'list', 'width=$winwidth, height=$winheight, scrollbars=yes');
		}
		//-->
		</script>\n~;

			if ($showadded == 2 || $showsmdir == 2) {
				$MCExtraSmilies .= q~
				<br />
				<script type="text/javascript">
				<!--
				function Smiliextra() {
					AddTxt=smiliecode[document.getElementById('smiliextra_list').value];
					AddText(AddTxt);
				}
				~;
                $smilieslist       = q{};
                $smilie_url_array  = q{};
                $smilie_code_array = q{};
				$i = 0;
				if ($showadded == 2) {
					while ($SmilieURL[$i]) {
                        $smilieslist .=
                          qq~    document.write('<option value="$i"~
                          . (
                            $SmilieDescription[$i] eq $showinbox
                            ? ' selected="selected"'
                            : q{}
                          ) . qq~>$SmilieDescription[$i]</option>');\n~;
                        if ( $SmilieURL[$i] =~ /\//ism ) {
                            $tmpurl = $SmilieURL[$i];
                        }
						else { $tmpurl = qq~$defaultimagesdir/$SmilieURL[$i]~; }
						$smilie_url_array .= qq~"$tmpurl", ~;
						$tmpcode = $SmilieCode[$i];
                        $tmpcode =~ s/\&quot;/"+'"'+"/gsm;    # "'
						FromHTML($tmpcode);
                        $tmpcode =~ s/&#36;/\$/gsm;
                        $tmpcode =~ s/&#64;/\@/gsm;
						$smilie_code_array .= qq~" $tmpcode", ~;
						$i++;
					}
				}
				if ($showsmdir == 2) {
					opendir DIR, "$htmldir/Smilies";
					@contents = readdir DIR;
					closedir DIR;

					foreach my $line ( sort { uc($a) cmp uc $b } @contents ) {
						( $name, $extension ) = split /\./xsm, $line;
						if (   $extension =~ /gif/ism
                            || $extension =~ /jpg/ism 
                            || $extension =~ /jpeg/ism
                            || $extension =~ /png/ism )
                        {
							if ( $line !~ /banner/ism ) {
								$smilieslist .=
                                  qq~	document.write('<option value="$i"~
                                  . (
                                    $name eq $showinbox
                                    ? ' selected="selected"'
                                    : q{}
                                  ) . qq~>$name</option>');\n~;
								$smilie_url_array .= qq~"$yyhtml_root/Smilies/$line", ~;
								$smilie_code_array .= qq~" [smiley=$line]", ~;
								$i++;
							}
						}
					}
				}
				$smilie_url_array  .= q~""~;
				$smilie_code_array .= q~""~;

				$MCExtraSmilies .= qq~
				smilieurl = new Array($smilie_url_array);
				smiliecode = new Array($smilie_code_array);
				document.write('<table class="bordercolor pad_2px cs_thin" style="height:90px; width:120px"><tr>');
				document.write('<td class="titlebg center h_15px"><span class="small"><b>$post_smiltxt{'1'}</b></span></td>');
				document.write('</tr><tr>');
				document.write('<td class="windowbg2 center vtop" style="height:20px"><select name="smiliextra_list" id="smiliextra_list" onchange="document.images.smiliextra_image.src=smilieurl[document.getElementById(\\'smiliextra_list\\').value]" style="width:114px; font-size:7pt;">');
				$smilieslist
				document.write('</select></td>');
				document.write('</tr><tr>');
				document.write('<td class="windowbg2 center" style="height:70px"><img name="smiliextra_image" src="'+smilieurl[0]+'" alt="" onclick="javascript: Smiliextra();" class="pointer"></td>');
				document.write('</tr><tr>');
				document.write('<td class="windowbg2 center" style="height:15px"><span class="small"><a href="javascript: smiliewin();">$post_smiltxt{'17'}</a></span></td>');
				document.write('</tr></table>');
				document.images.smiliextra_image.src = smilieurl[document.getElementById('smiliextra_list').value];
				//-->
				</script>
				<br />
				~;
			}
		}

	}
    else {
		$MCGlobalFormStart .=
qq~<form action="$scripturl?action=$destination" method="post" name="postmodify" id="postmodify" enctype="application/x-www-form-urlencoded">~;
	}

	###################################################
	########  right side container starts here
	###################################################
	if ($view eq 'mycenter') {
		LoadUserDisplay($username);

		my $onOffStatus =
          ${$uid.$username}{'offlinestatus'} eq 'away'
          ? $mycenter_txt{'onoffstatusaway'}
          : $mycenter_txt{'onoffstatuson'};

		my $stealthstatus = q{};
		if (($iamadmin || $iamgmod) && $enable_MCstatusStealth) {
			$stealthstatus = $mycenter_txt{'stealth_off'};
			if ( ${$uid.$username}{'stealth'} ) {
                $stealthstatus = $mycenter_txt{'stealth_on'};
            }
			$stealthstatus = qq~		<tr>
					<td class="windowbg2">$mycenter_txt{'stealth'}</td>
					<td class="windowbg2">'$stealthstatus'</td>
				</tr>~;
		}

		my $memberinfo = "$memberinfo{$username}$addmembergroup{$username}";
		my $userOnline = userOnLineStatus($username) . q~<br />~;
		my $template_postinfo =
            qq~$mycenter_txt{'posts'}: ~
            . NumberFormat(${$uid.$username}{'postcount'})
            . q~<br />~;
		my $userlocation;
		if (${$uid.$username}{'location'}) {
			$userlocation = qq~$mycenter_txt{'location'}: ~ . ${$uid.$username}{'location'} . q~<br />~;
		}

		$mctitle = $mycenter_txt{'welcometxt'};
		#################################
		$myprofileblock =~ s/({|<)yabb userlink(}|>)/$link{$username}/gsm;
		$myprofileblock =~ s/({|<)yabb memberinfo(}|>)/$memberinfo/gsm;
		$myprofileblock =~ s/({|<)yabb stars(}|>)/$memberstar{$username}/gsm;
		$myprofileblock =~ s/({|<)yabb useronline(}|>)/$userOnline/gsm;
        $myprofileblock =~
          s/({|<)yabb userpic(}|>)/${$uid.$username}{'userpic'}/gsm;
        $myprofileblock =~
          s/({|<)yabb usertext(}|>)/${$uid.$username}{'usertext'}/gsm;
		$myprofileblock =~ s/({|<)yabb postinfo(}|>)/$template_postinfo/gsm;
		$myprofileblock =~ s/({|<)yabb location(}|>)/$userlocation/gsm;
        $myprofileblock =~
          s/({|<)yabb gender(}|>)/${$uid.$username}{'gender'}/gsm;
		################################
		$myprofileblock =~ s/({|<)yabb .+?(}|>)//gsm;

		if ($buddyListEnabled) {
			if (${$uid.$username}{'buddylist'}) {
				LoadBuddyList();
				$buddiesCurrentStatus =
qq~$mycenter_txt{'buddylisttitle'}:<br />$buddiesCurrentStatus~;
			}
            else {
				$buddiesCurrentStatus = $mycenter_txt{'buddylistnone'};
			}
		}
        else {
			$buddiesCurrentStatus = q~&nbsp;~;
		}

		$MCContent .= qq~
		<table class="pad_5px cs_thin">
		    <col style="width:33%" />
			<tr>
				<td class="windowbg2 vtop">
					$myprofileblock
				</td>
				<td class="windowbg2 vtop">
					$buddiesCurrentStatus
				</td>
			</tr><tr>
				<td class="windowbg" colspan="2">
					$mycenter_txt{'currentsettings'}
				</td>
			</tr><tr>
				<td class="windowbg2">
					$mycenter_txt{'onoffstatus'}<br />
				</td>
				<td class="windowbg2">'$onOffStatus'</td>
			</tr>
			$stealthstatus
		</table>
		~;

	############### sending pm #######################
	}
    elsif ($view eq 'pm' && ($action eq 'imsend' || $action eq 'imsend2')) {
		my $sendTitle = $inmes_txt{'sendmess'};
		if ($sendBMess) { $sendTitle = $inmes_txt{'sendbroadmess'}; }
		$MCContent .= qq~
		$MCGlobalFormStart
		<table class="pad_5px">
			$imsend
		</table>
		</form>~;
		$MCGlobalFormStart = q{};

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
		drawPMView();

	}
    elsif ($view eq 'pm' && $action eq 'imshow') {
		$showIM = q{};
		if ($INFO{'id'} eq 'all') {
			my $BC;
			foreach (@dimmessages) {
				$showmessid = ( split /\|/xsm, $_ )[0];
				$showIM .= DoShowIM($showmessid);
				if ( $INFO{'caller'} == 5
                    && !${$username}{'PMbcRead' . $showmessid} )
                {
					${$username}{'PMbcRead'} .=
                      ${$username}{'PMbcRead'} ? ",$showmessid" : $showmessid;
					$BCnewMessage--;
                    $BC = 1;
				}
			}
			if ($BC) { buildIMS($username, 'update'); }
		}
        else {
			$showIM = DoShowIM($INFO{'id'});
			if ( $INFO{'caller'} == 5
                && !${$username}{'PMbcRead' . $INFO{'id'} } )
            {
				${$username}{'PMbcRead'} .=
                  ${$username}{'PMbcRead'} ? ",$INFO{'id'}" : $INFO{'id'};
				buildIMS($username, 'update');
				$BCnewMessage--;
			}
		}

        $MCContent .= $showIM;

	}
    elsif ($view eq 'pm' && $action eq 'pmsearch') {
		spam_protection();
		$yysearchmain = q{};
		require "$sourcedir/Search.pl";
        pmsearch();
        $MCContent .= $yysearchmain;
		$mctitle = "$pm_search{'desc'}";

	}
    elsif ($view eq 'profile') {
		## if user has had to go via id check, this restores their intended page
		$page = $INFO{'page'};
		if($page && $action ne $page) { $action = $page; }
        require "$sourcedir/Profile.pl";
        if    ( $action eq 'myprofileIM' )        { ModifyProfileIM(); }
        elsif ( $action eq 'myprofileIM2' )       { ModifyProfileIM2(); }
        elsif ( $action eq 'myprofile' )          { ModifyProfile(); }
        elsif ( $action eq 'myprofile2' )         { ModifyProfile2(); }
        elsif ( $action eq 'myprofileContacts' )  { ModifyProfileContacts(); }
        elsif ( $action eq 'myprofileContacts2' ) { ModifyProfileContacts2(); }
        elsif ( $action eq 'myprofileOptions' )   { ModifyProfileOptions(); }
        elsif ( $action eq 'myprofileOptions2' )  { ModifyProfileOptions2(); }
        elsif ( $action eq 'myprofileBuddy' )     { ModifyProfileBuddy(); }
        elsif ( $action eq 'myprofileBuddy2' )    { ModifyProfileBuddy2(); }
        elsif ( $action eq 'myviewprofile' )      { ViewProfile(); }
        elsif ( $action eq 'myprofileAdmin' )     { ModifyProfileAdmin(); }
        elsif ( $action eq 'myprofileAdmin2' )    { ModifyProfileAdmin2(); }
        $MCContent .= $showProfile;

	}
    elsif ($view eq 'notify') {
		require "$sourcedir/Notify.pl";
        if ( $action eq 'shownotify' ) { ShowNotifications(); }
        elsif ( $action eq 'boardnotify2' ) {
            BoardNotify2();
            ShowNotifications();
        }
        elsif ( $action eq 'notify4' ) { Notify4(); }
        $MCContent .= $showNotifications;

	}
    elsif ($view eq 'recentposts') {
        require "$sourcedir/Profile.pl";
        usersrecentposts();
        $MCContent .= $showProfile;

	}
    elsif ($view eq 'favorites'){
		require "$sourcedir/Favorites.pl";
        Favorites();
        $MCContent .= $showFavorites;
	}

	## start PM div
    if (   $PM_level == 1
        || ( $PM_level == 2 && $staff )
        || ( $PM_level == 3 && ( $iamadmin || $iamgmod ) ) )
    {
		$MCPmMenu .= qq~
	<div id="cont_pm" style="display: $display_pm">
		<table id="pms" class="windowbg2 pad_1px">
	    	<col style="width:15%" />
		    <col style="width:60%" />
		~;

		if (    ($PMenableBm_level == 1 && $staff )
             || ($PMenableBm_level == 2 && ($iamadmin || $iamgmod))
             || ($PMenableBm_level == 3 && $iamadmin))
        {
			$MCPmMenu .= qq~<tr>
				<td colspan="3">
					<span class="nav bold"><a href="$scripturl?action=imsend;bmess=yes">$img{'sendbmess'}</a></span>
				</td>
			</tr>~;
		}

		my $inboxNewCount =
qq~<span class="NewLinks">, <a href="$scripturl?action=imshow;caller=1;id=-1">${$username}{'PMimnewcount'} $inmes_txt{'new'}</a></span>~;
		if ( ${$username}{'PMimnewcount'} == 0 ) { $inboxNewCount = q{}; }

		$MCPmMenu .= qq~<tr>
		 		<td colspan="3"><span class="nav bold"><a href="$scripturl?action=imsend">$img{'im_send'}</a></span></td>
			</tr><tr>
				<td class="windowbg2"><img src="$imagesdir/im_inbox.gif" alt="$inmes_txt{'inbox'}" title="$inmes_txt{'inbox'}" /></td>
				<td class="windowbg2"><span class="nav bold"><a href="$scripturl?action=im">$inmes_txt{'inbox'}</a></span></td>
				<td class="windowbg2"><span class="nav">${$username}{'PMmnum'}$inboxNewCount</span></td>
			</tr>~;

		if ($PMenableBm_level > 0
           || ($PMenableGuestButton == 1 && ($iamadmin || $iamgmod)))
        {
			$inboxNewCount =
              $BCnewMessage
              ? " <span class='NewLinks'>($inmes_txt{'new'})</span>"
              : q{};
			$MCPmMenu .= qq~<tr>
				<td class="windowbg2"><img src="$imagesdir/im_inbox.gif" alt="$inmes_txt{'broadcast'}" title="$inmes_txt{'broadcast'}" /></td>
				<td class="windowbg2"><span class="nav bold"><a href="$scripturl?action=im;focus=bmess">$inmes_txt{'broadcast'}</a></span></td>
				<td class="windowbg2"><span class="nav">$BCCount$inboxNewCount</span></td>
			</tr>~;
		}

		my @folderCount = split /\|/xsm, ${$username}{'PMfoldersCount'};
		$MCPmMenu .= qq~<tr>
				<td class="windowbg2"><img src="$imagesdir/im_outbox.gif" alt="$inmes_txt{'draft'}" title="$inmes_txt{'draft'}" /></td>
				<td class="windowbg2"><span class="nav bold"><a href="$scripturl?action=imdraft">$inmes_txt{'draft'}</a></span>	</td>
				<td class="windowbg2"><span class="nav">${$username}{'PMdraftnum'}</span></td>
			</tr><tr>
				<td class="windowbg2"><img src="$imagesdir/im_outbox.gif" alt="$inmes_txt{'outbox'}" title="$inmes_txt{'outbox'}" /></td>
				<td class="windowbg2"><span class="nav bold"><a href="$scripturl?action=imoutbox">$inmes_txt{'outbox'}</a></span>	</td>
				<td class="windowbg2"><span class="nav">${$username}{'PMmoutnum'}</span></td>
			</tr><tr>
				<td colspan="3"><hr class="hr" /></td>
			</tr><tr>
				<td class="windowbg2"><img src="$imagesdir/imstore.gif" alt="$inmes_txt{'storage'}" title="$inmes_txt{'storage'}" /></td>
				<td class="windowbg2"><span class="small">$inmes_txt{'storage'}</span></td>
				<td class="windowbg2"><span class="nav">${$username}{'PMstorenum'}</span></td>
			</tr><tr>
				<td class="windowbg2">&nbsp;</td>
				<td class="windowbg2"><span class="nav">&nbsp; &nbsp;<b><a href="$scripturl?action=imstorage;viewfolder=in">$im_folders_txt{'in'}</a></b></span></td>
				<td class="windowbg2"><span class="nav">~;
        $MCPmMenu .= $folderCount[0] || 0;
        $MCPmMenu .= qq~</span></td>
			</tr><tr>
				<td class="windowbg2">&nbsp;</td>
				<td class="windowbg2"><span class="nav">&nbsp; &nbsp;<b><a href="$scripturl?action=imstorage;viewfolder=out">$im_folders_txt{'out'}</a></b> </span></td>
				<td class="windowbg2"><span class="nav">~;
       $MCPmMenu .= $folderCount[1] || 0;
       $MCPmMenu .= q~</span></td>
			</tr>~;

		## if there are some folders to show under storage
		## split the list down and show it with link to each folder
		if ($enable_storefolders > 0) {
			my $storeFoldersTotal = 0;
			my $DelAdFolder = 0;
			if (${$username}{'PMfolders'}) {
				my $x = 2;
				foreach
                  my $storefolder ( split /\|/xsm, ${$username}{'PMfolders'} )
                {
					if ($storefolder ne 'in' && $storefolder ne 'out') {
						$storeFoldersTotal++;
						$MCPmMenuTemp .= q~<tr>
							<td class="windowbg2" style="width:15%; padding-right:0">~;
						if ($storeFoldersTotal > 0 && $folderCount[$x] == 0) {
							$DelAdFolder = 1;
							$MCPmMenuTemp .= qq~
								<input type="checkbox" name="delfolder$x" id="delfolder$x" value="del" />~;
						}
                        else {
							$MCPmMenuTemp .= q~&nbsp;~;
						}

						$MCPmMenuTemp .= qq~
							</td>
							<td class="windowbg2 nav" style="width:60%">&nbsp; &nbsp;<b><a href="$scripturl?action=imstorage;viewfolder=$storefolder">$storefolder</a></b></td>
							<td class="windowbg2"><span class="nav">~;
						$MCPmMenuTemp .= $folderCount[$x] || 0;
						$MCPmMenuTemp .= q~</span></td>
						</tr>~;
					$x++;
					}
				}

				if ($DelAdFolder) {
					$MCPmMenuTemp .= qq~<tr>
							<td class="windowbg2" colspan="3">
							<input type="submit" name="deladdfolder" id="deladdfolder" value="$inmes_txt{'delete'}" class="button" />
							<input type="hidden" name="delfolders" id="delfolders" value="yes" />
							</td>
						</tr>~;
				}
			}

			if ($storeFoldersTotal) {
				$MCPmMenu .= qq~<tr>
						<td class="windowbg2" colspan="3">
							<form action="$scripturl?action=delpmfolder" method="post" name="delpmfolder" id="delpmfolder" enctype="application/x-www-form-urlencoded" style="display:inline;"  onsubmit="return submitproc()">
							<table class="pad_2px">
							    <col style="width:15%" />
							    <col style="width:60%" />						    
							$MCPmMenuTemp
							</table>
						</form>
						</td>
					</tr>~;
			}

			$MCPmMenu .= qq~<tr>
				<td colspan="3"><hr class="hr" /></td>
			</tr><tr>
				<td class="nav bold" colspan="3"><a href="javascript:MarkAllAsRead('$scripturl?action=markims','$imagesdir')">$inmes_txt{'764'}</a></td>
			</tr>~;
			$yyjavascript .=
qq~\nvar markallreadlang = '$inmes_txt{'500'}';\nvar markfinishedlang = '$inmes_txt{'500a'}';~;

			## this allows user to add a new folder on the fly
			if ($storeFoldersTotal < $enable_storefolders ) {
				$MCPmMenu .= qq~<tr>
				<td colspan="3">
					<hr  class="hr" />
					<form action="$scripturl?action=newpmfolder" method="post" name="newpmfolder" id="newpmfolder" enctype="application/x-www-form-urlencoded" style="display:inline;"  onsubmit="return submitproc()" accept-charset="$yycharset">
					<label for="newfolder">$inmes_imtxt{'newstorefolder'}</label><br />
					<input type="text" name="newfolder" id="newfolder" size="15" value="$mc_folders{'foldername'}" onfocus="txtInFields(this, '$mc_folders{'foldername'}');" onblur="txtInFields(this, '$mc_folders{'foldername'}')" />
					<input type="submit" name="addimfolder" id="addimfolder" value="$inmes_txt{'addfolder'}" class="button" />
					</form>
				</td>
			</tr>~;
			}
		}

        if ( $enable_PMsearch != 0 ) {
			$MCPmMenu .= qq~<tr>
				<td colspan="3">
				<hr class="hr" />
				<script src="$yyhtml_root/ubbc.js" type="text/javascript"></script>
				<label for="search">$pm_search{'desc'}</label><br />
				<form action="$scripturl?action=pmsearch" method="post" onsubmit="return submitproc()" style="display: inline" accept-charset="$yycharset">~;

			if ($view eq 'pm' && $action ne 'pmsearch') {
				$MCPmMenu .= qq~
				- <input type="radio" name="pmbox" id="pmboxall" value="" checked="checked" /> <label for="pmboxall">$pm_search{'all'}</label>
				<input type="radio" name="pmbox" id="pmboxthis" value="$callerid" /> <label for="pmboxthis">$pm_search{'justthis'}</label><br />~;
			}

			$MCPmMenu .= qq~
				- <input type="checkbox" name="searchtype" id="searchtype" value="user" /> <label for="searchtype">$pm_search{'byuser'}</label><br />
				<input type="text" name="search" id="search" size="16" style="font-size: 11px; vertical-align: middle;" />

				<input type="image" src="$imagesdir/search.gif" style="border: 0; background-color: transparent; margin-right: 5px; vertical-align: middle;" />
				</form>
				</td>
			</tr>~;
		}

		$MCPmMenu .= q~
		</table>
	</div>
		~;
	}
	## end PM div
    return;
}

sub drawPMView {
	## column headers
	## note - if broadcast messages not enabled but guest pm is, admin/gmod still
	##  see the broadcast split
	if (   ($enable_PMcontrols && ${$uid.$username}{'pmviewMess'})
        || (!$enable_PMcontrols && !$enable_PMviewMess) )
   {
		enable_yabbc();
	}
	if ($INFO{'sort'} ne 'gpdate' && $INFO{'sort'} ne 'thread') {
        pageLinksList();
    }
	my $dateColhead = "$inmes_txt{'317'}";
	if ($action eq 'imdraft') { $dateColhead = $inmes_txt{'datesave'}; }

	$mctitle = $IM_box;
	$MCContent .= q~
	<table class="bordercolor cs_thin">
	    <col style="width:65%" />
	    <col style="width:15%" />
	~;

	if (($#dimmessages >= $maxmessagedisplay || $INFO{'start'} =~ /all/sm )
       && $action ne 'imstorage')
    {
		$MCContent .= qq~<tr>
		<td class="titlebg" style="padding:4px 4px 4px 7px;" colspan="3">$pageindex1$pageindexjs</td>
	</tr>~;
	}

	if ($INFO{'viewfolder'} ne q{} ) { 
       $vfolder = qq~;viewfolder=$INFO{'viewfolder'}~;
    }
	if ($INFO{'focus'} eq 'bmess') { $vbmess = q~;focus=bmess~; }
	if ($INFO{'sort'} ne 'gpdate') { $sbgpdate = q~;sort=gpdate~; }

    if ( $action ne 'imstorage' || $INFO{'viewfolder'} ne q{} ) {
		$MCContent .= qq~<tr>
	    <td class="titlebg padd_3px"><b>$inmes_txt{'70'}</b></td>
	    <td class="titlebg padd_3px"><b>$senderinfo</b></td>
	    <td class="titlebg padd_3px"><b><a href="$scripturl?action=$action$sbgpdate$vfolder$vbmess">$dateColhead</a></b></td>
	  </tr>~;
	}

	## if no messages found in file, say so
	my $storeContentFound = 0;
	if ($INFO{'viewfolder'} && @dimmessages) {
		foreach my $checkPost (@dimmessages) {
			my $thisStorefolder= (split /\|/xsm, $checkPost)[13];
			if ($thisStorefolder eq $INFO{'viewfolder'}) {
                $storeContentFound = 1;
                last;
            }
		}
	}

	if (!@dimmessages || ($storeContentFound == 0 && $INFO{'viewfolder'})) {
		## drop in the 'no messages' text
		$MCContent .= qq~<tr>
	    <td class="windowbg padd_3px" style="height:21px" colspan="3">$inmes_txt{'151'}</td>
	  </tr>
	</table>
	<br class="clear" /><br />
	~;
	}
    else {
		## set colours for display
		$acount++;
		my $sortBy = $INFO{'sort'};
		my $maxcounter;
		$start = $start || 0;
		## if on last page, adjust the maxcounter down
		if ((($#dimmessages + 1) - $start) < $maxmessagedisplay
           || $sortBy eq 'gpdate'
           || $action eq 'imstorage')
        {
		    $maxcounter = @dimmessages;
		}
        else {
		    $maxcounter = ($start + $maxmessagedisplay);
		}
		my $viewBMess;
		my $groupByDate = 0;
		my $dateSpan = 0;
		my $latestPM = 0;
		if ($INFO{'focus'} eq 'bmess') { $viewBMess = 1; }
		if ($sortBy eq 'gpdate') {
			my $topMDate = (split /\|/xsm, $dimmessages[0])[6];
			my $oldestDate = (split /\|/xsm, $dimmessages[-1])[6];
			$groupByDate = 1;
			## work out the span of days - today less oldest message, in days
			$dateSpan = int(($date - $oldestDate) / 86_400); # in days
			$latestPM = (($date - $topMDate) / 3600); # in hours
		}
		## if sort is grouped, extra block is added per group
		## pull date of newest pm

		my $latestDateSet = 0;
		my $lastWeekSet = 0;
		my $twoWeeksSet = 0;
		my $threeWeeksSet = 0;
		my $monthSet = 0;
		my $gtMonthSet = 0;
		my $uselegend = q{};

		# work out the newest pm date soa s to put the right first block in
		if ($dateSpan > 31) { $gtMonthSet = 1; $uselegend = 'older'; }
		if ($dateSpan > 21 && ($latestPM / 24) < 32 ) {
           $monthSet = 1;
           $uselegend = 'fourweeks';
        }
		if ($dateSpan > 14 && ($latestPM / 24) < 22 ) {
            $threeWeeksSet = 1;
            $uselegend = 'threeweeks';
        }
		if ($dateSpan > 7  && ($latestPM / 24) < 15 ) {
            $twoWeeksSet = 1;
            $uselegend = 'twoweeks';
        }
		if ($dateSpan > 1 && ($latestPM / 24) < 8 ) {
            $lastWeekSet = 1;
            $uselegend = 'oneweek';
        }
		if ($latestPM < 24) { $latestDateSet = 1; $uselegend = 'latest'; }

		if ($sortBy eq 'gpdate') {
			$MCContent .= qq~<tr>
	    <td class="titlebg" colspan="3"><span class="imgtitlebg">$im_sorted{$uselegend}</span>	</td>
	  </tr>~;

			$counterCheck = $start;
		}
		if ($viewBMess) { $stkDateSet = 1; }

        foreach my $counter ( $start .. ( $maxcounter - 1 ) ) {
##########  top of messages list ##########
# $messageid, $musername, $musernameto, $musernamecc, $musernamebcc
			$class_PM_list =
              $class_PM_list eq 'windowbg2' ? 'windowbg' : 'windowbg2';
			chomp $dimmessages[$counter];
            my (
                $messageid,    $musername,    $musernameto,
                $musernamecc,  $musernamebcc, $msub,
                $mdate,        $immessage,    $mpmessageid,
                $mreplyno,     $mips,         $messStatus,
                $messageFlags, $storeFolder,  $messageAttachment
            ) = split /\|/xsm, $dimmessages[$counter];
			## if we are viewing  one of the storage folders, filter out the
			##  PMs that do not match
			if ( $action eq 'imstorage' && $INFO{'viewfolder'} ne $storeFolder)
            {
				$class_PM_list =
                  $class_PM_list eq 'windowbg2' ? 'windowbg' : 'windowbg2';
				next;
			}
			## set the status icon
			my $messIconName = 'standard';
			if ($messStatus =~ m/c/sm) { $messIconName = 'confidential'; }
			elsif ($messStatus =~ m/u/sm) { $messIconName = 'urgent'; }
			elsif ($messStatus =~ m/a/sm || $messStatus =~ m/ga/sm ) { $messIconName = 'alertmod'; }
			elsif ($messStatus =~ m/gr/sm) {
                $messIconName = 'guestpmreply';
            }
            elsif ( $messStatus =~ m/g/sm ) { $messIconName = 'guestpm'; }
			my $messIcon =
qq~<img src="$imagesdir/$messIconName.gif"  alt="$im_message_status{$messIconName}" title="$im_message_status{$messIconName}" style="margin:0 15px;vertical-align: middle;" />~;

			my ($hasMultiRecs);
			if ($musernameto =~ /,/xsm || $musernamecc || $musernamebcc ) {
                $hasMultiRecs = 1;
            }

			## if store, set the from/to

			# check for multiple recs (outbox/store/draft only)
			## and build the to/rec string for individual callback
			my %usersRec;

            my $usernameto = q{};
            if (   $action eq 'imoutbox'
                || $action eq 'imstorage'
                || $action eq 'imdraft' )
            {
				if ($hasMultiRecs) {
					my $switchComma = 0;
					$usernameto = q{};
					if ($messStatus !~ /b/sm) {
						## check each to see if they read the message
						foreach my $muser (split /\,/xsm, $musernameto) {
							$userToMessRead =
                              checkIMS($muser, $messageid, 'messageopened');
							%usersRec =
                              {%usersRec , $muser => $userToMessRead};
							if (!$yyUDLoaded{$muser}) { LoadUser($muser); }
							if ($usernameto && $switchComma == 0) {
                                $usernameto .= q~ ...~;
                                $switchComma = 1;
                            }
							elsif (!$usernameto) {
								$usernameto =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$muser}" rel="nofollow">$format_unbold{$muser}</a>~;
							}
						}
						if ($musernamecc) {
						## check each to see if they read the message
							foreach my $muser (split /\,/xsm, $musernamecc ) {
								$userToMessRead = checkIMS($muser, $messageid,
                                    'messageopened');
								%usersRec =
                                 {%usersRec , $muser => $userToMessRead};
								if ( !$yyUDLoaded{$muser}) {
                                     LoadUser($muser);
                                }
								if ($usernameto && $switchComma == 0) {
                                    $usernameto .= q~ ...~;
                                    $switchComma = 1;
                                }
							}
						}
						if ($musernamebcc) {
							## check each to see if they read the message
							foreach my $muser (split /\,/xsm, $musernamebcc ) {
								$userToMessRead = checkIMS($muser, $messageid,
                                    'messageopened');
								%usersRec =
                                 {%usersRec , $muser => $userToMessRead};
								if (!$yyUDLoaded{$muser}) {
                                    LoadUser($muser);
                                }
								if($usernameto && $switchComma == 0) {
                                   $usernameto .= q~ ...~;
                                   $switchComma = 1;
                                }
							}
						}
					}
                     else {
						foreach my $muser (split /\,/xsm, $musernameto) {
							if ($muser eq 'all') {
                                $usernameto = $inmes_txt{'bmallmembers'};
                            }
                            elsif ( $muser eq 'mods' ) {
                                $usernameto = $inmes_txt{'bmmods'};
                            }
                            elsif ( $muser eq 'gmods' ) {
                                $usernameto = $inmes_txt{'bmgmods'};
                            }
                            elsif ( $muser eq 'admins' ) {
                                $usernameto = $inmes_txt{'bmadmins'};
                            }
							else {
								my $title =
                                 (split /\|/xsm, $NoPost{$muser})[0];
								$usernameto = $title;
							}
							if ($usernameto && $switchComma == 0) {
                                $usernameto .= q~ ...~;
                                $switchComma = 1;
                                last;
                            }
						}
					}
				}
                else {
					if ( $messStatus !~ /b/sm ) {
						$userToMessRead =
                          checkIMS($musernameto, $messageid, 'messageopened');
						if (!$yyUDLoaded{$musernameto}) {
                            LoadUser($musernameto);
                        }
						$usernameto =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$musernameto}" rel="nofollow">$format_unbold{$musernameto}</a>~;
					}
                    else {
						if ($musernameto eq 'all') {
                            $usernameto = $inmes_txt{'bmallmembers'};
                        }
                        elsif ( $musernameto eq 'mods' ) {
                            $usernameto = $inmes_txt{'bmmods'};
                        }
                        elsif ( $musernameto eq 'gmods' ) {
                            $usernameto = $inmes_txt{'bmgmods'};
                        }
                        elsif ( $musernameto eq 'admins' ) {
                            $usernameto = $inmes_txt{'bmadmins'};
                        }
						else {
                            my $title =
                              ( split /\|/xsm, $NoPost{$musernameto} )[0];
							$usernameto = $title;
						}
					}
				}
			}
			## done multi
			## kill if not needed
			if (!$hasMultiRecs) { undef %usersRec; }

			## time to output name
			# for multi recs, have to split it down and test per user
			## happens for any message sent with cc or bcc
			my $checkz = 0;
			my $allChecked = 0;

			$msub = Censor($msub);
			ToChars($msub);

			$mydate = timeformat($mdate);
			## start of message row 1
			## for inbox or store, check from
            my ( $messageIcon, $callBack );
            if ( $action ne 'imstorage' && $action ne 'imdraft' && !$viewBMess )
            {
				## detect multi-rec
				my ($imnew, $imRepliedTo, $imOpened);
				## outbox - has the recp opened the message? (allow for multi)
				if ($action eq 'imoutbox' && !$hasMultiRecs ) {
					$imOpened =
                      checkIMS($musernameto, $messageid, 'messageopened');
				}
                elsif ($action eq 'im') { ## inbox - has user opened ?
					$imOpened =
                       checkIMS($username, $messageid, 'messageopened');
				}
				if ($action eq 'im') {
                    $imRepliedTo =
                      checkIMS($username, $messageid, 'messagereplied');
                }

				## viewing inbox
				if ($action eq 'im') {
					## not opened
					if (!$imOpened && !$hasMultiRecs) {
						$messageIcon =
qq~<img src="$imagesdir/imclose.gif" alt="$inmes_imtxt{'innotread'}" title="$inmes_imtxt{'innotread'}" />~;
					}
					## replied to
					elsif ($imRepliedTo && !$hasMultiRecs) {
						$messageIcon =
qq~<img src="$imagesdir/answered.gif" alt="$inmes_imtxt{'08'}" title="$inmes_imtxt{'08'}" />~;
					}
					## opened
					elsif ($imOpened && !$hasMultiRecs) {
						$messageIcon =
qq~<img src="$imagesdir/imopen.gif" alt="$inmes_imtxt{'inread'}" title="$inmes_imtxt{'inread'}" />~;
					}
					## not opened multi
					elsif (!$imOpened && $hasMultiRecs) {
						$messageIcon =
qq~<img src="$imagesdir/imclose2.gif" alt="$inmes_imtxt{'inread'}" title="$inmes_imtxt{'inread'}" />~;
					}
					## opened multi
					elsif ($imOpened && $hasMultiRecs) {
						$messageIcon =
qq~<img src="$imagesdir/imopen2.gif" alt="$inmes_imtxt{'inread'}" title="$inmes_imtxt{'inread'}" />~;
					}
				}

				##  outbox
				elsif ($action eq 'imoutbox') {
					## not opened
					if (!$imOpened && !$hasMultiRecs) {
						LoadUser($musernameto);
						if (${$uid.$musernameto}{'notify_me'} < 2
                           || $enable_notifications < 2)
                        {
							$messageIcon =
qq~<img src="$imagesdir/imclose.gif" alt="$inmes_imtxt{'outnotread'}" title="$inmes_imtxt{'outnotread'}" />~;
							$callBack =
qq~<span class="small"><a href="$scripturl?action=imcb;rid=$messageid;receiver=$useraccount{$musernameto}" onclick="return confirm('$inmes_imtxt{'73'}')">$inmes_imtxt{'83'}</a> | </span>~;
						}
                        else {
							$messageIcon =
qq~<img src="$imagesdir/imclose.gif" alt="$inmes_imtxt{'outnotread'}" title="$inmes_imtxt{'outnotread'}" />~;
						}
					}
					## opened
					elsif ($imOpened && !$hasMultiRecs) {
                        $messageIcon =
                          $messageFlags =~ /c/ism
                          ? qq~<img src="$imagesdir/imcallback.gif"  alt="$inmes_imtxt{'callback'}" title="$inmes_imtxt{'callback'}" />~
                          : qq~<img src="$imagesdir/imopen.gif"  alt="$inmes_imtxt{'outread'}" title="$inmes_imtxt{'outread'}" />~;
					}

					## for multi rec, and none opened
					if ($hasMultiRecs) {
						my ($countrecepients,$countread,@receivers);
						my $tousers = $musernameto;
                        if ($musernamecc)  { $tousers .= ",$musernamecc"; }
                        if ($musernamebcc) { $tousers .= ",$musernamebcc"; }
                        foreach my $recname ( split /,/xsm, $tousers ) {
							$countrecepients++;
							LoadUser($recname);
							if (
                                checkIMS($recname, $messageid,
                                    'messageopened')
                                || (${$uid.$recname}{'notify_me'} > 1
                                    && $enable_notifications > 1)
                               )
                              { 
                                  $countread++;
                              }
                              else { push @receivers, $useraccount{$recname}; }
						}
						if (!$countread) {
							$messageIcon =
qq~<img src="$imagesdir/imclose2.gif" alt="$inmes_imtxt{'outmultinotread'}" title="$inmes_imtxt{'outmultinotread'}" />~;
							$callBack =
qq~<span class="small"><a href="$scripturl?action=imcb;rid=$messageid;receiver=~
                              . join(q{,}, @receivers)
                              . qq~" onclick="return confirm('$inmes_imtxt{'73'}')">$inmes_imtxt{'83'}</a> | </span>~;
						}
                         elsif ($countrecepients == $countread) {
							$messageIcon =
                               $messageFlags =~ /c/ism
                               ? qq~<img src="$imagesdir/imcallback2.gif" alt="$inmes_imtxt{'outmulticallback'}" title="$inmes_imtxt{'outmulticallback'}" />~
                               : qq~<img src="$imagesdir/imopen2.gif" alt="$inmes_imtxt{'outmultiread'}" title="$inmes_imtxt{'outmultiread'}" />~;
						}
                        else {
							$messageIcon =
                               $messageFlags =~ /c/ism
                               ? qq~<img src="$imagesdir/imcallback3.gif" alt="$inmes_imtxt{'outsomemulticallback'}" title="$inmes_imtxt{'outsomemulticallback'}" />~
                               : qq~<img src="$imagesdir/imopen3.gif" alt="$inmes_imtxt{'outmultisomeread'}" title="$inmes_imtxt{'outmultisomeread'}" />~;
							$callBack =
qq~<span class="small"><a href="$scripturl?action=imshow;id=$messageid;caller=2">$inmes_imtxt{'multicallback'}</a> | </span>~;
						}
					}
				}
			}

			## switch action if opening a draft - want this sending to the 'send' screen
			my $actString = 'imshow';
			if ($action eq 'imdraft') { $actString = 'imsend'; }

			## if grouping, check bar here
			if ($stkmess && $sortBy ne 'gpdate' && $normDateSet && $viewBMess)
            {
				## sticky messages
				$normDateSet = 0;
				$MCContent .= qq~<tr>
	    <td class="titlebg" colspan="3"><span class="imgtitlebg">$im_sorted{'standart'}</span></td>
	  </tr>~;
			}

			if ($stkmess
             && $sortBy ne 'gpdate'
             && $stkDateSet
             && $viewBMess
             && ($messStatus =~ m/g/sm || $messStatus =~ m/a/sm ) )
           {
				## sticky messages
				$stkDateSet = 0;
				$MCContent .= qq~<tr>
	    <td class="titlebg" colspan="3"><span class="imgtitlebg">$im_sorted{'important'}</span></td>
	  </tr>~;
			}

			if ($sortBy eq 'gpdate') {
				$uselegend = q{};
				if ($latestDateSet
                  && ($date - $mdate)/86_400 > 1
                  && $counter > $counterCheck)
                {
						$latestDateSet = 0;
						if ($lastWeekSet) {
                        if ( ( $date - $mdate ) / 86_400 <= 7 ) { $counterCheck = $counter; }
							$uselegend = 'oneweek';
						}
				}

                if (   $lastWeekSet
                    && ( $date - $mdate ) / 86_400 > 7
                    && $counter > $counterCheck )
                {
						$lastWeekSet = 0;
						if ($twoWeeksSet) {
                        if ( ( $date - $mdate ) / 86_400 <= 14 ) { $counterCheck = $counter; }
							$uselegend = 'twoweeks';
						}
				}

                if (   $twoWeeksSet
                    && ( $date - $mdate ) / 86_400 > 14
                    && $counter > $counterCheck )
                {
						$twoWeeksSet = 0;
						if ($threeWeeksSet) {
                        if ( ( $date - $mdate ) / 86_400 <= 21 ) { $counterCheck = $counter;}
							$uselegend = 'threeweeks';
						}
				}

                if (   $threeWeeksSet
                    && ( $date - $mdate ) / 86_400 > 21
                    && $counter > $counterCheck )
                {
						$threeWeeksSet = 0;
						if ($monthSet) {
                        if (( $date - $mdate ) / 86_400 <= 31) { $counterCheck = $counter ;}
							$uselegend = 'fourweeks';
						}
				}

                if (   $monthSet
                    && ( $date - $mdate ) / 86_400 > 31
                    && $counter > $counterCheck )
                {
						$monthSet = 0;
						if ($gtMonthSet) { $uselegend = 'older'; }
				}
                if ($uselegend) {
				$MCContent .= qq~<tr>
	    <td class="titlebg" colspan="3"><span class="imgtitlebg">$im_sorted{$uselegend}</span></td>
	  </tr>~;
  			    }
            }

			my $BCnew;
			if ($action eq 'im'
             && $viewBMess
             && !${$username}{'PMbcRead' . $messageid})
            {
				$BCnew = qq~&nbsp;<img src="$imagesdir/new.gif" alt="" />~;
			}

			$MCContent .= qq~<tr>
	    <td class="$class_PM_list">$BCnew$messageIcon$messIcon<a href="$scripturl?action=$actString;caller=$callerid;id=$messageid">$msub</a></td>
	    <td class="$class_PM_list">~;

			if ($action eq 'im'
               || ($action eq 'imstorage' && $INFO{'viewfolder'} eq 'in'))
            {
				if ($messStatus eq 'g' || $messStatus eq 'ga' ) {
					my ($guestName, $guestEmail) = split / /sm, $musername;
					$guestName =~ s/%20/ /gsm;
					$usernamefrom =
qq~$guestName<br />(<a href="mailto:$guestEmail">$guestEmail</a>)~;
				}
                else {
					LoadUser($musername); # is from user
					$usernamefrom =
                      ${$uid.$musername}{'realname'}
                      ? qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$musername}" rel="nofollow">$format_unbold{$musername}</a>~
                      : (
                          $musername ? qq~$musername ($maintxt{'470a'})~
                        : $maintxt{'470a'}
                       ); # 470a == Ex-Member
				}
				$MCContent .= $usernamefrom; # [inbox / broadcast / storage in]

			}
            elsif ($action eq 'imoutbox'
                || ($action eq 'imstorage' && $INFO{'viewfolder'} eq 'out'))
            {
				my @usernameto;
				if ($messStatus eq 'gr') {
					my ($guestName, $guestEmail) = split / /sm, $musernameto;
					$guestName =~ s/%20/ /gsm;
					$usernameto[0] =
qq~$guestName<br />(<a href="mailto:$guestEmail">$guestEmail</a>)~;
				}
                elsif ($messStatus =~ /b/sm ) {
					foreach my $uname (split /,/xsm, $musernameto ) {
						if ($uname eq 'all') {
                            push @usernameto, $inmes_txt{'bmallmembers'};
						}
                        elsif ( $uname eq 'mods' ) {
                            push @usernameto, $inmes_txt{'bmmods'};
						}
                        elsif ( $uname eq 'gmods' ) {
                            push @usernameto, $inmes_txt{'bmgmods'};
						}
                        elsif ( $uname eq 'admins' ) {
                            push @usernameto, $inmes_txt{'bmadmins'};
						}
                        else {
                            my ( $title, undef ) =
                              split /\|/xsm, $NoPost{$uname}, 2;
							push @usernameto, $title;
						}
					}
                }
                else {
					my $uname = $musernameto; # is to user
                    if ($musernamecc) { $uname .= ",$musernamecc"; }
					if ($musernamebcc) {
						if ($musername eq $username) {
							$uname .= ",$musernamebcc";
						}
                        else {
							foreach (split /,/xsm, $musernamebcc) {
								if ($_ eq $username) {
                                    $uname .= ",$username";
                                    last;
                                }
							}
						}
					}
					foreach my $uname (split /,/xsm, $uname) {
						LoadUser($uname);
                        push(
                            @usernameto,
                            (
                                ${ $uid . $uname }{'realname'}
                                ? qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$uname}" rel="nofollow">$format_unbold{$uname}</a>~
                                : (
                                      $uname ? qq~$uname ($maintxt{'470a'})~
                                    : $maintxt{'470a'}
                                )
                            )
                        );    # 470a == Ex-Member
					}
				}
                $MCContent .= join q{, }, @usernameto;  # [outbox / storage out]

			}
            elsif ($action eq 'imdraft') {
				my @usernameto;
				if ($messStatus =~ /b/sm) {
					foreach my $uname (split /,/xsm, $musernameto) {
                        if ( $uname eq 'all' ) {
                            push @usernameto, $inmes_txt{'bmallmembers'};
						}
                        elsif ( $uname eq 'mods' ) {
                            push @usernameto, $inmes_txt{'bmmods'};
                        }
                        elsif ( $uname eq 'gmods' ) {
                            push @usernameto, $inmes_txt{'bmgmods'};
					}
                        elsif ( $uname eq 'admins' ) {
                            push @usernameto, $inmes_txt{'bmadmins'};
                        }
                        else {
                            my ( $title, undef ) =
                              split /\|/xsm, $NoPost{$uname}, 2;
                            push @usernameto, $title;
                        }
                    }
                }
                else {
					my $uname = $musernameto; # is to user
                    if ($musernamecc) { $uname .= ",$musernamecc"; }
					if ($musernamebcc) {
						if ($musername eq $username) {
							$uname .= ",$musernamebcc";
						}
                        else {
							foreach (split /,/xsm, $musernamebcc) {
                                if ( $_ eq $username ) {
                                    $uname .= ",$username";
                                    last;
							}
						}
					}
                    }
					foreach my $uname (split /,/xsm, $uname) {
						LoadUser($uname);
                        push(
                            @usernameto,
                            (
                                ${ $uid . $uname }{'realname'}
                                ? qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$uname}" rel="nofollow">$format_unbold{$uname}</a>~
                                : (
                                      $uname ? qq~$uname ($maintxt{'470a'})~
                                    : $maintxt{'470a'}
                                )
                            )
                        );    # 470a == Ex-Member
					}
				}
                $MCContent .= join q{, }, @usernameto;    # [draft]

            }
            else {
				my @usernameto;
				if ($messStatus eq 'g' || $messStatus eq 'ga' ) {
					my ($guestName, $guestEmail) = split / /sm, $musername;
					$guestName =~ s/%20/ /gsm;
					$usernamefrom =
qq~$guestName<br />(<a href="mailto:$guestEmail">$guestEmail</a>)~;

					my $uname = $musernameto; # is to user
                    if ($musernamecc) { $uname .= ",$musernamecc"; }
					if ($musernamebcc) {
						if ($musername eq $username) {
							$uname .= ",$musernamebcc";
						}
                        else {
							foreach (split /,/xsm, $musernamebcc) {
                                if ( $_ eq $username ) {
                                    $uname .= ",$username";
                                    last;
							}
						}
					}
                    }
					foreach my $uname (split /,/xsm, $uname) {
						LoadUser($uname);
                        push(
                            @usernameto,
                            (
                                ${ $uid . $uname }{'realname'}
                                ? qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$uname}" rel="nofollow">$format_unbold{$uname}</a>~
                                : (
                                      $uname ? qq~$uname ($maintxt{'470a'})~
                                    : $maintxt{'470a'}
                                )
                            )
                        );    # 470a == Ex-Member
					}
                    $usernameto = join q{, }, @usernameto;

				}
                elsif ($messStatus eq 'gr') {
					my ($guestName, $guestEmail) = split / /sm, $musernameto;
					$guestName =~ s/%20/ /gsm;
					$usernameto =
qq~$guestName<br />(<a href="mailto:$guestEmail">$guestEmail</a>)~;

					LoadUser($musername); # is from user
					$usernamefrom =
                      ${$uid.$musername}{'realname'} 
                      ? qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$musername}" rel="nofollow">$format_unbold{$musername}</a>~
                      : (
                         $musername ? qq~$musername ($maintxt{'470a'})~
                       : $maintxt{'470a'}
                     ); # 470a == Ex-Member

				}
                elsif ($messStatus =~ /b/sm) {
					foreach my $uname (split /,/xsm, $musernameto) {
						if ($uname eq 'all') {
                            push @usernameto, $inmes_txt{'bmallmembers'};
                        }
                        elsif ( $uname eq 'mods' ) {
                            push @usernameto, $inmes_txt{'bmmods'};
                        }
                        elsif ( $uname eq 'gmods' ) {
                            push @usernameto, $inmes_txt{'bmgmods'};
                        }
                        elsif ( $uname eq 'admins' ) {
                            push @usernameto, $inmes_txt{'bmadmins'};
                        }
                        else {
                            my ( $title, undef ) =
                              split /\|/xsm, $NoPost{$uname}, 2;
                            push @usernameto, $title;
						}
					}
                    $usernameto = join q{, }, @usernameto;

					LoadUser($musername); # is from user
					$usernamefrom =
                       ${$uid.$musername}{'realname'}
                      ? qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$musername}" rel="nofollow">$format_unbold{$musername}</a>~
                       : (
                           $musername ? qq~$musername ($maintxt{'470a'})~
                         : $maintxt{'470a'}
                       ); # 470a == Ex-Member

				}
                else {
					my $uname = $musernameto; # is to user
                    if ($musernamecc) { $uname .= ",$musernamecc"; }
					if ($musernamebcc) {
						if ($musername eq $username) {
							$uname .= ",$musernamebcc";
						}
                        else {
							foreach (split /,/xsm, $musernamebcc) {
                                if ( $_ eq $username ) {
                                    $uname .= ",$username";
                                    last;
                                }
							}
						}
					}
                    foreach my $uname ( split /,/xsm, $uname ) {
                        LoadUser($uname);
                        push(
                            @usernameto,
                            (
                                ${ $uid . $uname }{'realname'}
                                ? qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$uname}" rel="nofollow">$format_unbold{$uname}</a>~
                                : (
                                      $uname ? qq~$uname ($maintxt{'470a'})~
                                    : $maintxt{'470a'}
                                )
                            )
                        );    # 470a == Ex-Member
					}
                    $usernameto = join q{, }, @usernameto;

                    LoadUser($musername);    # is from user
                    $usernamefrom =
                      ${ $uid . $musername }{'realname'}
                      ? qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$musername}" rel="nofollow">$format_unbold{$musername}</a>~
                      : (
                          $musername ? qq~$musername ($maintxt{'470a'})~
                        : $maintxt{'470a'}
                      );                     # 470a == Ex-Member
				}
				$MCContent .= qq~$usernamefrom / $usernameto~; #[store other]
			}
			$MCContent .= qq~</td>
	    <td class="$class_PM_list">$mydate</td>
			~;

			undef $quotecount;
			undef $codecount;
            $quoteimg = q{};
            $codeimg  = q{};

			if ($UseMenuType != 1) { $sepa = '&nbsp;|&nbsp;'; }
			else { $sepa = $menusep; }
			## inline list for msg
			my ($actionsMenu, $actionsMenuselect, $storefolderView);
			$mreplyno++;
			## build actionsMenu for output
			if ($action eq 'im' && !$viewBMess) {
				$actionsMenu =
qq~<a href="$scripturl?action=imsend;caller=$callerid;quote=$mreplyno;to=$useraccount{$musername};id=$messageid">$inmes_txt{'145'}</a>$sepa<a href="$scripturl?action=imsend;caller=$callerid;reply=$mreplyno;to=$useraccount{$musername};id=$messageid">$inmes_txt{'146'}</a>$sepa<a href="$scripturl?action=imsend;caller=$callerid;forward=1;quote=$mreplyno;id=$messageid">$inmes_txt{'147'}</a>$sepa<a href="$scripturl?action=deletemultimessages;caller=$callerid;deleteid=$messageid" onclick="return confirm('$inmes_txt{'770'}')">$inmes_txt{'remove'}</a>~;

			## broadcast messages can only be quoted on!
			}
            elsif ($action eq 'im' && $viewBMess) {
				if ($messStatus eq 'g') {
					$actionsMenu =
qq~<a href="$scripturl?action=imsend;caller=$callerid;quote=$mreplyno;replyguest=1;id=$messageid">$inmes_txt{'146'}</a>~;
				}
                else {
					$actionsMenu =
qq~<a href="$scripturl?action=imsend;caller=$callerid;quote=$mreplyno;id=$messageid">$inmes_txt{'145'}</a>$sepa<a href="$scripturl?action=imsend;caller=$callerid;reply=$mreplyno;to=$useraccount{$musername};id=$messageid">$inmes_txt{'146'}</a>~;
				}
				if ($iamadmin || $username eq $musername) {
					$actionsMenu .=
qq~$sepa<a href="$scripturl?action=deletemultimessages;caller=$callerid;deleteid=$messageid" onclick="return confirm('$inmes_txt{'770'}')">$inmes_txt{'remove'}</a>~;
                    $deleteButton = 1;
				}

			## for others
			}
            elsif ($action eq 'imdraft') {
				$actionsMenu =
qq~<a href="$scripturl?action=deletemultimessages;caller=$callerid;deleteid=$messageid" onclick="return confirm('$inmes_txt{'770'}')">$inmes_txt{'remove'}</a>~;
			}
            elsif ($action eq 'imoutbox') {
				$actionsMenu =
qq~$callBack<a href="$scripturl?action=deletemultimessages;caller=$callerid;deleteid=$messageid" onclick="return confirm('$inmes_txt{'770'}')">$inmes_txt{'remove'}</a>~;
			}
            else {
				if ($action eq 'imstorage') {
                    $storefolderView = ";viewfolder=$INFO{'viewfolder'}";
                }
				if ($messStatus =~ /gr/sm) {
					$actionsMenu =
qq~<a href="$scripturl?action=deletemultimessages;caller=$callerid;deleteid=$messageid$storefolderView" onclick="return confirm('$inmes_txt{'770'}')">$inmes_txt{'remove'}</a>~;
				}
                else {
					$actionsMenu =
qq~$callBack<a href="$scripturl?action=imsend;caller=$callerid;quote=$mreplyno;to=$useraccount{$musername};id=$messageid">$inmes_txt{'145'}</a>$sepa<a href="$scripturl?action=imsend;caller=$callerid;reply=$mreplyno;to=$useraccount{$musername};id=$messageid">$inmes_txt{'146'}</a>$sepa<a href="$scripturl?action=imsend;caller=$callerid;forward=1;id=$messageid">$inmes_txt{'147'}</a>$sepa<a href="$scripturl?action=deletemultimessages;caller=$callerid;deleteid=$messageid$storefolderView" onclick="return confirm('$inmes_txt{'770'}')">$inmes_txt{'remove'}</a>~;
				}
			}
			if (!$viewBMess
               || ($viewBMess && ($iamadmin || $username eq $musername)))
            {
				$actionsMenuselect =
qq~<input type="checkbox" name="message$messageid" id="message$messageid" class="$class_PM_list" value="1" style="cursor: hand;" /> <label for="message$messageid">$inmes_txt{'delete'}</label>~;
				if ($action ne 'imdraft' && !$viewBMess) {
                    $actionsMenuselect .=
qq~/<label for="message$messageid">$inmes_imtxt{'store'}</label>~;
                }
			}
			$MCContent .= qq~
	  </tr><tr>
	    <td colspan="3" class="$class_PM_list" style="height:21px">
			~;

            if (
                ( $enable_PMcontrols && ${ $uid . $username }{'pmviewMess'} )
                || (  !$enable_PMcontrols
                    && $enable_PMviewMess
                    && ${ $uid . $username }{'pmviewMess'} )
              )
            {
                if ( $immessage =~ /\[quote(.*?)\]/isgm ) {
                    $quoteimg =
qq~<img src="$imagesdir\/quote.gif" alt="$inmes_imtxt{'69'}" title="$inmes_imtxt{'69'}" \/>&nbsp;~;
                    $immessage =~ s/\[quote(.*?)\](.+?)\[\/quote\]//igsm;
                }
                if ( $immessage =~ /\[code\s*(.*?)\]/isgm ) {
                    $codeimg =
qq~<img src="$imagesdir\/code1.gif" alt="$inmes_imtxt{'84'}" title="$inmes_imtxt{'84'}" \/>&nbsp;~;
                    $immessage =~ s/\[code\s*(.*?)\](.+?)\[\/code\]//igsm;
                }
                $immessage =~ s/<br.*?>/&nbsp;/gism;
                $immessage =~ s/&nbsp;&nbsp;/ /gsm;
                ToChars($immessage);
                $immessage =~ s/\[.*?\]//gsm;
                FromChars($immessage);
				$convertstr = $immessage;
				$convertcut = 100;
                CountChars();
				$immessage = $convertstr;
				ToChars($immessage);
                if ($cliped) { $immessage .= q{...}; }
				$immessage = qq~$quoteimg$codeimg $immessage~;
                $immessage = Censor($immessage);

                if ( $immessage !~ s/#nosmileys//isgm ) {
					$message = $immessage;
					enable_yabbc();
                    MakeSmileys();
					$immessage = $message;
				}
				$MCContent .= qq~
		$immessage<br /><br />
        <hr class="hr" />
				~;
			}
			$MCContent .= qq~
		<div style="float: left; text-align: left; width: 65%;"><span class="small">$actionsMenu</span></div>
		<div style="float: right; text-align: right; width: 35%;"><span class="small">$actionsMenuselect</span></div>
		</td>
	  </tr>~;
			$acount++;
			if ($acount == $stkmess +1) { $normDateSet = 1; }
		}
################ end of message loop ###################

		## limiter bar
		if ($enable_imlimit == 1 && !$viewBMess) {
			my $impercent = 0;
			my $imbar = 0;
			my $imrest = 0;
			my $messageCounter = @dimmessages;
			if ($action eq 'im' && !$viewBMess) {
				if ($messageCounter != 0 && $numibox != 0) {
					$impercent = int(100 / $numibox * $messageCounter);
					$imbar = int(200 / $numibox * $messageCounter);
				}

				$intext =
qq~($inmes_imtxt{'13'} $messageCounter $inmes_imtxt{'01'} $numibox $inmes_imtxt{'19'} $inmes_txt{'inbox'} $inmes_txt{'folder'})~;
			}

			elsif ($action eq 'imoutbox') {
				if ($messageCounter != 0 && $numobox != 0) {
					$impercent = int(100 / $numobox * $messageCounter);
					$imbar = int(200 / $numobox * $messageCounter);
				}
				$intext =
qq~($inmes_imtxt{'13'} $messageCounter $inmes_imtxt{'01'} $numobox $inmes_imtxt{'19'} $inmes_txt{'outbox'} $inmes_txt{'folder'})~;
			}

			elsif ($action eq 'imdraft') {
				if ($messageCounter != 0 && $numdraft != 0) {
					$impercent = int(100 / $numdraft * $messageCounter);
					$imbar = int(200 / $numdraft * $messageCounter);
				}
				$intext =
qq~($inmes_imtxt{'13'} $messageCounter $inmes_imtxt{'01'} $numdraft $inmes_imtxt{'19'} $inmes_txt{'draft'} $inmes_txt{'folder'})~;
			}
			elsif ($action eq 'imstorage') {
				if ($messageCounter != 0 && $numstore != 0) {
					$impercent = int(100 / $numstore * $messageCounter);
					$imbar = int(200 / $numstore * $messageCounter);
				}
				$intext =
qq~($inmes_imtxt{'13'} $messageCounter $inmes_imtxt{'01'} $numstore $inmes_imtxt{'19'} $inmes_txt{'storage'} $inmes_txt{'folder'})~;
			}
			$imrest = 200 - $imbar;
			if ($imbar > 200) { $imbar  = 200; }
			if ($imrest <= 0) { $dorest = q{}; }
			else {
                $dorest =
qq~<img src="$imagesdir/usageempty.gif" height="8" width="$imrest" alt="" />~;
            }
			$imbargfx =
qq~$inmes_imtxt{'67'}:&nbsp;<img src="$imagesdir/usage.gif" alt="" /><img src="$imagesdir/usagebar.gif" height="8" width="$imbar" alt="" />$dorest<img src="$imagesdir/usage.gif" alt="" />&nbsp;$impercent&nbsp;%&nbsp;<br />~;
		}
         else {
			$intext = q~&nbsp;~;
			$imbargfx = q~&nbsp;~;
		}
        if ( $action ne 'imstorage' || $INFO{'viewfolder'} ne q{} ) {
            $removeButton =
qq~<input type="submit" name="imaction" value="$inmes_txt{'remove'}" class="button" onclick="return confirm('$inmes_txt{'delmultipms'}');" />~;
            $inmes_txt{'777'} =~ s/REMOVE/$removeButton/sm;
			$removeButton = $inmes_txt{'777'};
		}
		if (@dimmessages) {
			$MCContent .= qq~<tr>
	    <td class="titlebg right" style="height:21px" colspan="3">
			~;
			if (!$viewBMess) {
                if ( $imbargfx || $intext ) { $MCContent .= qq~
		<span class="small"><b>$imbargfx&nbsp;$intext</b><br /><br /></span>~;
                }
                if ( $action ne 'imstorage' || $INFO{'viewfolder'} ne q{} ) {
                    $MCContent .= $movebutton;
			    }
			}
            if ( !$viewBMess
                || ( $viewBMess && ( $iamadmin || $deleteButton ) ) )
            {
                $MCContent .= qq~ $removeButton<br /><br />~;
            }
            $MCContent .= q~
	    </td>
	  </tr>~;

            if (
                (
                    !$viewBMess
                    || ( $viewBMess && ( $iamadmin || $deleteButton ) )
                )
                && !( $action eq 'imstorage' && $INFO{'viewfolder'} eq q{} )
              )
            {
				$MCContent .= qq~<tr>
	    <td class="windowbg right" colspan="3">
		<div style="float: right;">
		  <label for="delete_store"><i>$inmes_txt{'737'}</i></label>&nbsp;<input type="checkbox" id="delete_store" name="delete_store" onclick="if (this.checked) checkAll(); else uncheckAll();" />
		</div>
		<br />
		<script type="text/javascript">
			<!--
			function checkAll() {
				for (var i = 0; i < document.searchform.elements.length; i++) {
					document.searchform.elements[i].checked = true;
				}
			}
			function uncheckAll() {

				for (var i = 0; i < document.searchform.elements.length; i++) {
				document.searchform.elements[i].checked = false;
				}
			}
			// -->
		</script>
	    </td>
	  </tr>~;
			}
		}
		$MCContent .= q~
		</table>
		~;
	}
    return;
}

# load user's buddylist and show status of said members
sub LoadBuddyList {
	# Load background color list
    my @cssvalues = qw ( windowbg2 windowbg );
	my $cssnum = @cssvalues;
	my $counter = 0;

    my @buddies = split /\|/xsm, ${ $uid . $username }{'buddylist'};
	chomp @buddies;
	$buddiesCurrentStatus = qq~
		<table class="pad_1px cs_thin">
		    <tr class="catbg">
                <td class="center">$profile_txt{'68a'}</td>
                <td class="center">$profile_txt{'68b'}</td>
                <td class="center"><img src="$imagesdir/imclose.gif" alt="$profile_txt{'69a'}" title="$profile_txt{'69a'}" /></td>
                <td class="center"><img src="$imagesdir/email.gif" alt="$profile_txt{'69'}" title="$profile_txt{'69'}" /></td>
                <td class="center"><img src="$imagesdir/www.gif" alt="$profile_txt{'96'}" title="$profile_txt{'96'}" /></td>
           </tr>~;
	foreach my $buddyname (@buddies) {
		$css = $cssvalues[($counter % $cssnum)];
		my ($buddyrealname);
		my ($online, $buddyemail, $buddypm, $buddywww) = '&nbsp;';
		if (-e "$memberdir/$buddyname.vars") {
			LoadUser($buddyname);
			$online = userOnLineStatus($buddyname);
			$buddyrealname = ${$uid.$buddyname}{'realname'};
			$usernamelink = $link{$buddyname};

			if (${$uid.$buddyname}{'hidemail'}
              && !$iamadmin
              && $allow_hide_email == 1)
            {
				$buddyemail =
qq~<img src="$imagesdir/lockmail.gif" alt="$mycenter_txt{'hiddenemail'}" title="$mycenter_txt{'hiddenemail'}" />~;
			}
             else {
				$buddyemail =
qq~<a href="mailto:${$uid.$buddyname}{'email'}"><img src="$imagesdir/email.gif" alt="$profile_txt{'889'} ${$uid.$buddyname}{'email'}" title="$profile_txt{'889'} ${$uid.$buddyname}{'email'}" /></a>~;
			}

            CheckUserPM_Level($buddyname);
            if (
                   $PM_level == 1
                || ( $PM_level == 2 && $UserPM_Level{$buddyname} > 1 && $staff )
                || (   $PM_level == 3
                    && $UserPM_Level{$buddyname} == 3
                    && ( $iamadmin || $iamgmod ) )
              )
            {
                $buddypm =
qq~<a href="$scripturl?action=imsend;to=$useraccount{$buddyname}"><img src="$imagesdir/imclose.gif"  alt="$profile_txt{'688'} $buddyrealname" title="$profile_txt{'688'} $buddyrealname" /></a>~;
			}

            if (!$minlinkweb) { $minlinkweb = 0; }
            if (${$uid.$buddyname}{'weburl'} && (${$uid.$buddyname}{'postcount'} >= $minlinkweb || ${$uid.$buddyname}{'position'} eq 'Administrator' || ${$uid.$buddyname}{'position'} eq 'Global Moderator' || ${$uid.$buddyname}{'position'} eq 'YaBB Moderator')) { 
				$buddywww =
qq~<a href="${$uid.$buddyname}{'weburl'}" onclick="target='_blank';"><img src="$imagesdir/www.gif" alt="${$uid.$buddyname}{'webtitle'}" title="${$uid.$buddyname}{'webtitle'}" /></a>~;
			}
		}
        else {
			$usernamelink = $mycenter_txt{'buddydeleted'}; # Ex-Member
		}
		$buddiesCurrentStatus .= qq~<tr class="$css">
        <td>$usernamelink</td><td class="center">$online</td>
        <td class="center">$buddypm</td>
        <td class="center">$buddyemail</td>
        <td class="center">$buddywww</td>
    </tr>~;
		$counter++;
	}
	undef %UserPM_Level;
    $buddiesCurrentStatus .= '</table>';
	return $buddiesCurrentStatus;
}

sub mcMenu {
	my ($pmclass, $profclass, $postclass);
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
        if (   $PM_level == 0
            || ( $PM_level == 2 && !$staff )
            || ( $PM_level == 3 && !$iamadmin && !$iamgmod ) )
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

	my $tabsep =
qq~<img src="$imagesdir/tabsep211.png" alt="" style="float: left; vertical-align: middle;" />~;
	my $tabfill =
qq~<img src="$imagesdir/tabfill.gif" alt="" />~;
    if (   $PM_level == 1
        || ( $PM_level == 2 && $staff )
        || ( $PM_level == 3 && ( $iamadmin || $iamgmod ) ) )
    {
        $yymcmenu .=
qq~<span onclick="changeToTab('pm'); return false;"$pmclass id="menu_pm"><a href="$scripturl?action=mycenter" onclick="changeToTab('pm'); return false;" style="padding: 3px 0 4px 0; ">$tabfill$mc_menus{'messages'}$tabfill</a></span>$tabsep
		~;
	}
	# profile link
	$yymcmenu .=
qq~<span onclick="changeToTab('prof'); return false;"$profclass id="menu_prof"><a href="$scripturl?action=myviewprofile;username=$useraccount{$username}" onclick="changeToTab('prof'); return false;" style="padding: 3px 0 4px 0; ">$tabfill$mc_menus{'profile'}$tabfill</a></span>
	~;

	# posts link
	$yymcmenu .=
qq~$tabsep<span onclick="changeToTab('posts'); return false;"$postclass  id="menu_posts"><a href="$scripturl?action=favorites" onclick="changeToTab('posts'); return false;" style="padding: 3px 0 4px 0; ">$tabfill$mc_menus{'posts'}$tabfill</a></span>
	~;

	$yymcmenu .= qq~$tabsep~;
    return;
}

1;