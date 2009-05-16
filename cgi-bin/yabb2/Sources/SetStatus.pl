###############################################################################
# SetStatus.pl                                                                #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.4                                                    #
# Packaged:       April 12, 2009                                              #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2009 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
# Sponsored by: Xnull Internet Media, Inc. - http://www.ximinc.com            #
#               Your source for web hosting, web design, and domains.         #
###############################################################################

$setstatusplver = 'YaBB 2.4 $Revision: 1.10 $';
if ($action eq 'detailedversion') { return 1; }

sub SetStatus {
	&fatal_error('no_access') unless ($iammod || $iamadmin || $iamgmod);

	my $start      = $INFO{'start'} || 0;
	my $status     = substr($INFO{'action'}, 0, 1) || substr($FORM{'action'}, 0, 1);
	my $threadid   = $INFO{'thread'};
	my $thisstatus = '';

	if (!$currentboard) {
		&MessageTotals("load", $threadid);
		$currentboard = ${$threadid}{'board'};
	}

	fopen(BOARDFILE, "$boardsdir/$currentboard.txt") || &fatal_error("cannot_open","$boardsdir/$currentboard.txt", 1);
	@boardfile = <BOARDFILE>;
	fclose(BOARDFILE);

	fopen(BOARDFILE, ">$boardsdir/$currentboard.txt") || &fatal_error("cannot_open","$boardsdir/$currentboard.txt", 1);
	foreach my $line (@boardfile) {
		if ($line =~ m~\A$threadid\|~) {
			my ($mnum, $msub, $mname, $memail, $mdate, $mreplies, $musername, $micon, $mstate) = split(/\|/, $line);
			chomp $mstate;

			$mstate .= 0 if $mstate !~ /0/;

			if ($mstate =~ /$status/) {
				$mstate =~ s/$status//ig;
				# Sticky-ing redirects to messageindex always
				# Also handle message index
				if ($status eq 's' || $INFO{'tomessageindex'}) {
					$yySetLocation = qq~$scripturl?board=$currentboard~;
				} else {
					$yySetLocation = qq~$scripturl?num=$threadid/$start~;
				}
			} else {
				$mstate .= $status;
				$yySetLocation = qq~$scripturl?board=$currentboard~;
			}
			$thisstatus = $mstate;

			print BOARDFILE "$mnum|$msub|$mname|$memail|$mdate|$mreplies|$musername|$micon|$mstate\n";

		} elsif ($line =~ /\|/) {
			print BOARDFILE $line;
		}
	}
	fclose(BOARDFILE);

	&MessageTotals("load",$threadid);
	${$threadid}{'threadstatus'} = $thisstatus;
	&MessageTotals("update",$threadid);

	&BoardSetLastInfo($currentboard);
	if (!$INFO{'moveit'}) {
		&redirectexit;
	}
}

1;