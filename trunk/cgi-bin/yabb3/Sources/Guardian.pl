###############################################################################
# Guardian.pl                                                                 #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 3.0 Beta                                               #
# Packaged:       October 05, 2010                                            #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2010 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################

$guardianplver = 'YaBB 3.0 Beta $Revision$';

$not_from   = qq~$webmaster_email~;
$not_to     = qq~$webmaster_email~;
$abuse_time = &timeformat($date,1,0,1);
$abuse_time =~ s/<.*?>(.*?)<\/.*?>/$1/g;

sub guard {
	if (!$use_guardian) { return; }

	# Proxy Blocker
	if ($disallow_proxy_on && !$iamadmin) {
		my @possible_proxy_ips = get_alternative_ips();

		my @white_list = split(/\|/, $whitelist);
		foreach my $proxyip (@possible_proxy_ips) {
			my $whitelisted = 0;
			foreach (@white_list) {
				chomp $_;
				if ($_ ne "" && $proxyip =~ m/$_/) {
					$whitelisted = 1;
					last; 
				}
			}
			if (!$whitelisted) {
				if ($disallow_proxy_notify) {
					&LoadLanguage('Guardian');
					$not_subject = qq~$guardian_txt{'main'}-($mbname): $guardian_txt{'proxy_abuse'} $guardian_txt{'abuse'}~;
					$not_body    = qq~$guardian_txt{'proxy_abuse'} $guardian_txt{'abuse'} $maintxt{'30'} $abuse_time\n\n~;
					$not_body .= qq~$guardian_txt{'abuse_user'}: $username -> (${$uid.$username}{'realname'})\n~;
					$not_body .= qq~$guardian_txt{'abuse_ip'}: $user_ip, (REMOTE_ADDR)->$ENV{'REMOTE_ADDR'}, (HTTP_X_FORWARDED_FOR)->$ENV{'HTTP_X_FORWARDED_FOR'}, (HTTP_CLIENT_IP)->$ENV{'HTTP_CLIENT_IP'}, (X_IP_CLIENT)->$ENV{'X_IP_CLIENT'}, (HTTP_VIA)->$ENV{'HTTP_VIA'}\n~;
					if ($use_htaccess && $disallow_proxy_htaccess && !$iamadmin && !$iamgmod) {
						$not_body .= qq~$guardian_txt{'htaccess_added'}: $user_ip,\n\n~;
					}
					$not_body .= qq~$mbname, $guardian_txt{'main'}~;
					$not_subject =~ s~\&trade\;~~g;
					$not_body    =~ s~\&trade\;~~g;
					&guardian_notify($not_to, $not_subject, $not_body, $not_from);
				}
				if ($use_htaccess && $disallow_proxy_htaccess && !$iamadmin && !$iamgmod) {
					&update_htaccess("add", $user_ip);
				}
				&fatal_error("proxy_reason");
			}
		}
	}

	# Basic Value Setup
	$querystring = &get_query_string;

	# Check for Referer
	if ($referer_on) {
		@refererlist = split(/\|/, lc($banned_referers));
		$streferer = lc(&get_referer);
		foreach (@refererlist) {
			chomp $_;
			if ($streferer =~ m/$_/ && $_ ne "") {
				&LoadLanguage('Guardian');
				if ($referer_notify) {
					$not_subject = qq~$guardian_txt{'main'}-($mbname): $guardian_txt{'referer_abuse'} $guardian_txt{'abuse'}~;
					$not_body    = qq~$guardian_txt{'referer_abuse'} $guardian_txt{'abuse'} $maintxt{'30'} $abuse_time\n\n~;
					$not_body .= qq~$guardian_txt{'abuse_user'}: $username -> (${$uid.$username}{'realname'})\n~;
					$not_body .= qq~$guardian_txt{'abuse_ip'}: $user_ip\n~;
					if ($use_htaccess && $referer_htaccess && !$iamadmin && !$iamgmod) {
						$not_body .= qq~$guardian_txt{'htaccess_added'}: $user_ip,\n~;
					}
					$not_body .= qq~$guardian_txt{'abuse_referer'}: $streferer\n\n~;
					$not_body .= qq~$mbname, $guardian_txt{'main'}~;
					$not_subject =~ s~\&trade\;~~g;
					$not_body    =~ s~\&trade\;~~g;
					&guardian_notify($not_to, $not_subject, $not_body, $not_from);
				}
				if ($use_htaccess && $referer_htaccess && !$iamadmin && !$iamgmod) {
					&update_htaccess("add", $user_ip);
				}
				&fatal_error("referer_reason");
			}
		}
	}

	# Check for Harvester
	if ($harvester_on) {
		@harvesterlist = split(/\|/, lc($banned_harvesters));
		$agent = lc(&get_user_agent);
		foreach (@harvesterlist) {
			chomp $_;
			if ($agent =~ m/$_/ && $_ ne "") {
				if ($harvester_notify) {
					&LoadLanguage('Guardian');
					$not_subject = qq~$guardian_txt{'main'}-($mbname): $guardian_txt{'harvester_abuse'} $guardian_txt{'abuse'}~;
					$not_body    = qq~$guardian_txt{'harvester_abuse'} $guardian_txt{'abuse'} $maintxt{'30'} $abuse_time\n\n~;
					$not_body .= qq~$guardian_txt{'abuse_user'}: $username -> (${$uid.$username}{'realname'})\n~;
					$not_body .= qq~$guardian_txt{'abuse_ip'}: $user_ip\n~;
					if ($use_htaccess && $harvester_htaccess && !$iamadmin && !$iamgmod) {
						$not_body .= qq~$guardian_txt{'htaccess_added'}: $user_ip,\n~;
					}
					$not_body .= qq~$guardian_txt{'abuse_harvester'}: $agent\n\n~;
					$not_body .= qq~$mbname, $guardian_txt{'main'}~;
					$not_subject =~ s~\&trade\;~~g;
					$not_body    =~ s~\&trade\;~~g; 
					&guardian_notify($not_to, $not_subject, $not_body, $not_from);
				}
				if ($use_htaccess && $harvester_htaccess && !$iamadmin && !$iamgmod) {
					&update_htaccess("add", $user_ip);
				}
				&fatal_error("harvester_reason");
			}
		}
	}

	# Check for Request
	if ($request_on) {
		@requestlist = split(/\|/, lc($banned_requests));
		$method = lc(&get_request_method);
		foreach (@requestlist) {
			chomp $_;
			if ($method =~ m/$_/ && $_ ne "") {
				if ($request_notify) {
					&LoadLanguage('Guardian');
					$not_subject = qq~$guardian_txt{'main'}-($mbname): $guardian_txt{'request_abuse'} $guardian_txt{'abuse'}~;
					$not_body    = qq~$guardian_txt{'request_abuse'} $guardian_txt{'abuse'} $maintxt{'30'} $abuse_time\n\n~;
					$not_body .= qq~$guardian_txt{'abuse_user'}: $username -> (${$uid.$username}{'realname'})\n~;
					$not_body .= qq~$guardian_txt{'abuse_ip'}: $user_ip\n~;
					if ($use_htaccess && $request_htaccess && !$iamadmin && !$iamgmod) {
						$not_body .= qq~$guardian_txt{'htaccess_added'}: $user_ip,\n~;
					}
					$not_body .= qq~$guardian_txt{'abuse_request'}: $method\n\n~;
					$not_body .= qq~$mbname, $guardian_txt{'main'}~;
					$not_subject =~ s~\&trade\;~~g;
					$not_body    =~ s~\&trade\;~~g;
					&guardian_notify($not_to, $not_subject, $not_body, $not_from);
				}
				if ($use_htaccess && $request_htaccess && !$iamadmin && !$iamgmod) {
					&update_htaccess("add", $user_ip);
				}
				&fatal_error("request_reason");
			}
		}
	}

	# Check for Strings
	if ($string_on) {
		require "$sourcedir/SubList.pl";
		my ($temp_query, $testkey);
		$temp_query = lc($querystring);
		@stringlist = split(/\|/, lc($banned_strings));
		foreach (@stringlist) {
			chomp $_;
			foreach $testkey(keys %director){			## strip off all existing command strings from the temporary query ##
				chomp $testkey;
				$temp_query =~ s/$testkey//g;
			}
			if ($temp_query =~ m/$_/ && $_ ne "") {
				if ($string_notify) {
					&LoadLanguage('Guardian');
					$not_subject = qq~$guardian_txt{'main'}-($mbname): $guardian_txt{'string_abuse'} $guardian_txt{'abuse'}~;
					$not_body    = qq~$guardian_txt{'string_abuse'} $guardian_txt{'abuse'} $maintxt{'30'} $abuse_time\n\n~;
					$not_body .= qq~$guardian_txt{'abuse_user'}: $username -> (${$uid.$username}{'realname'})\n~;
					$not_body .= qq~$guardian_txt{'abuse_ip'}: $user_ip\n~;
					if ($use_htaccess && $string_htaccess && !$iamadmin && !$iamgmod) {
						$not_body .= qq~$guardian_txt{'htaccess_added'}: $user_ip,\n~;
					}
					$not_body .= qq~$guardian_txt{'abuse_string'}: $_\n~;
					$not_body .= qq~$guardian_txt{'abuse_environment'}: $querystring\n\n~;
					$not_body .= qq~$mbname, $guardian_txt{'main'}~;
					$not_subject =~ s~\&trade\;~~g;
					$not_body    =~ s~\&trade\;~~g;
					&guardian_notify($not_to, $not_subject, $not_body, $not_from);
				}
				if ($use_htaccess && $string_htaccess && !$iamadmin && !$iamgmod) {
					&update_htaccess("add", $user_ip);
				}
				&fatal_error("string_reason","($_)");
			}
		}
	}

	# Check for UNION attack (for MySQL database protection only)
	if ($union_on) {
		if ($querystring =~ m/%20union%20/ || $querystring =~ m/\*\/union\/\*/) {
			if ($union_notify) {
				&LoadLanguage('Guardian');
				$not_subject = qq~$guardian_txt{'main'}-($mbname): $guardian_txt{'union_abuse'} $guardian_txt{'abuse'}~;
				$not_body    = qq~$guardian_txt{'union_abuse'} $guardian_txt{'abuse'} $maintxt{'30'} $abuse_time\n\n~;
				$not_body .= qq~$guardian_txt{'abuse_user'}: $username -> (${$uid.$username}{'realname'})\n~;
				$not_body .= qq~$guardian_txt{'abuse_ip'}: $user_ip\n~;
				if ($use_htaccess && $union_htaccess && !$iamadmin && !$iamgmod) {
					$not_body .= qq~$guardian_txt{'htaccess_added'}: $user_ip,\n~;
				}
				$not_body .= qq~$guardian_txt{'abuse_environment'}: $querystring\n\n~;
				$not_body .= qq~$mbname, $guardian_txt{'main'}~;
				$not_subject =~ s~\&trade\;~~g;
				$not_body    =~ s~\&trade\;~~g;
				&guardian_notify($not_to, $not_subject, $not_body, $not_from);
			}
			if ($use_htaccess && $union_htaccess && !$iamadmin && !$iamgmod) {
				&update_htaccess("add", $user_ip);
			}
			&fatal_error("union_reason");
		}
	}

	# Check for CLIKE attack (for MySQL database protection only)
	if ($clike_on) {
		if ($querystring =~ m/\/\*/) {
			if ($clike_notify) {
				&LoadLanguage('Guardian');
				$not_subject = qq~$guardian_txt{'main'}-($mbname): $guardian_txt{'clike_abuse'} $guardian_txt{'abuse'}~;
				$not_body    = qq~$guardian_txt{'clike_abuse'} $guardian_txt{'abuse'} $maintxt{'30'} $abuse_time\n\n~;
				$not_body .= qq~$guardian_txt{'abuse_user'}: $username -> (${$uid.$username}{'realname'})\n~;
				$not_body .= qq~$guardian_txt{'abuse_ip'}: $user_ip\n~;
				if ($use_htaccess && $clike_htaccess && !$iamadmin && !$iamgmod) {
					$not_body .= qq~$guardian_txt{'htaccess_added'}: $user_ip,\n~;
				}
				$not_body .= qq~$guardian_txt{'abuse_environment'}: $querystring\n\n~;
				$not_body .= qq~$mbname, $guardian_txt{'main'}~;
				$not_subject =~ s~\&trade\;~~g;
				$not_body    =~ s~\&trade\;~~g;
				&guardian_notify($not_to, $not_subject, $not_body, $not_from);
			}
			if ($use_htaccess && $clike_htaccess && !$iamadmin && !$iamgmod) {
				&update_htaccess("add", $user_ip);
			}
			&fatal_error("clike_reason");
		}
	}

	# Check for SCRIPTING attack
	if ($script_on) {
		while (($key, $secvalue) = each(%INFO)) {
			$secvalue = lc($secvalue);
			&str_replace("%3c", "<", $secvalue);
			&str_replace("%3e", ">", $secvalue);
			if (($secvalue =~ m/<[^>]script*\"?[^>]*>/) || ($secvalue =~ m/<[^>]*object*\"?[^>]*>/) || ($secvalue =~ m/<[^>]*iframe*\"?[^>]*>/) || ($secvalue =~ m/<[^>]*applet*\"?[^>]*>/) || ($secvalue =~ m/<[^>]*meta*\"?[^>]*>/) || ($secvalue =~ m/<[^>]*style*\"?[^>]*>/) || ($secvalue =~ m/<[^>]*form*\"?[^>]*>/) || ($secvalue =~ m/\([^>]*\"?[^)]*\)/) || ($secvalue =~ m/\"/)) {
				if ($script_notify) {
					&LoadLanguage('Guardian');
					$not_subject = qq~$guardian_txt{'main'}-($mbname): $guardian_txt{'script_abuse'} $guardian_txt{'abuse'}~;
					$not_body    = qq~$guardian_txt{'script_abuse'} $guardian_txt{'abuse'} $maintxt{'30'} $abuse_time\n\n~;
					$not_body .= qq~$guardian_txt{'abuse_user'}: $username -> (${$uid.$username}{'realname'})\n~;
					$not_body .= qq~$guardian_txt{'abuse_ip'}: $user_ip\n~;
					if ($use_htaccess && $script_htaccess && !$iamadmin && !$iamgmod) {
						$not_body .= qq~$guardian_txt{'htaccess_added'}: $user_ip,\n~;
					}
					$not_body .= qq~$guardian_txt{'abuse_url_environment'}: $secvalue\n\n~;
					$not_body .= qq~$mbname, $guardian_txt{'main'}~;
					$not_subject =~ s~\&trade\;~~g;
					$not_body    =~ s~\&trade\;~~g;
					&guardian_notify($not_to, $not_subject, $not_body, $not_from);
				}
				if ($use_htaccess && $script_htaccess && !$iamadmin && !$iamgmod) {
					&update_htaccess("add", $user_ip);
				}
				&fatal_error("script_reason");
			}
		}
		while (($key, $secvalue) = each(%FORM)) {
			$secvalue = lc($secvalue);
			$secvalue =~ s/\[code.*?\/code\]//gs if $key eq 'message' and $action =~ /^(post|modify|imsend)2$/;
			&str_replace("%3c", "<", $secvalue);
			&str_replace("%3e", ">", $secvalue);
			if (($secvalue =~ m/<[^>]script*\"?[^>]*>/) || ($secvalue =~ m/<[^>]style*\"?[^>]*>/)) {
				if ($script_notify) {
					&LoadLanguage('Guardian');
					$not_subject = qq~$guardian_txt{'main'}-($mbname): $guardian_txt{'script_abuse'} $guardian_txt{'abuse'}~;
					$not_body    = qq~$guardian_txt{'script_abuse'} $guardian_txt{'abuse'} $maintxt{'30'} $abuse_time\n\n~;
					$not_body .= qq~$guardian_txt{'abuse_user'}: $username -> (${$uid.$username}{'realname'})\n~;
					$not_body .= qq~$guardian_txt{'abuse_ip'}: $user_ip\n~;
					if ($use_htaccess && $script_htaccess && !$iamadmin && !$iamgmod) {
						$not_body .= qq~$guardian_txt{'htaccess_added'}: $user_ip,\n~;
					}
					$not_body .= qq~$guardian_txt{'abuse_form_environment'}: $secvalue\n\n~;
					$not_body .= qq~$mbname, $guardian_txt{'main'}~;
					$not_subject =~ s~\&trade\;~~g;
					$not_body    =~ s~\&trade\;~~g;
					&guardian_notify($not_to, $not_subject, $not_body, $not_from);
				}
				if ($use_htaccess && $script_htaccess && !$iamadmin && !$iamgmod) {
					&update_htaccess("add", $user_ip);
				}
				&fatal_error("script_reason");
			}
		}
	}
	return;
}


sub guardian_notify {
	require "$sourcedir/Mailer.pl";
	my ($to, $subject, $body, $from) = @_;
	my $result = &sendmail($to, $subject, $body, $from);
}

sub get_remote_port {
	if ($ENV{'REMOTE_PORT'}) {
		return $ENV{'REMOTE_PORT'};
	} else {
		return "empty";
	}
}

sub get_request_method {
	if ($ENV{'REQUEST_METHOD'}) {
		return $ENV{'REQUEST_METHOD'};
	} else {
		return "empty";
	}
}

sub get_script_name {
	if ($ENV{'SCRIPT_NAME'}) {
		return $ENV{'SCRIPT_NAME'};
	} else {
		return "empty";
	}
}

sub get_http_host {
	if ($ENV{'HTTP_HOST'}) {
		return $ENV{'HTTP_HOST'};
	} else {
		return "empty";
	}
}

sub get_query_string {
	if ($ENV{'QUERY_STRING'}) {
		my $tempstring = &str_replace("%09", "%20", $ENV{'QUERY_STRING'});
		return &str_replace("%09", "%20", $ENV{'QUERY_STRING'});
	} else {
		return "empty";
	}
}

sub get_user_agent {
	if ($ENV{'HTTP_USER_AGENT'}) {
		return $ENV{'HTTP_USER_AGENT'};
	} else {
		return "empty";
	}
}

sub get_referer {
	if ($ENV{'HTTP_REFERER'}) {
		return $ENV{'HTTP_REFERER'};
	} else {
		return "empty";
	}
}

sub str_replace {
	my ($org, $repl, $target) = @_;
	$target =~ s~$org~$repl~ig;
	return $target;
}

sub update_htaccess {
	my ($action, $value) = @_;
	my ($htheader, $htfooter, @denies, @htout);
	if (!$action) { return 0; }

	# header to determine only who has access to the main script, not the admin script
	$htheader = qq~<Files YaBB*>~;
	$htfooter = qq~</Files>~;
	$start = 0;
	foreach (&read_DBorFILE(1,'',".",'','htaccess')) {
		chomp $_;
		if ($_ eq $htheader) { $start = 1; }
		if ($start == 0 && $_ !~ m/#/ && $_ ne "") { push(@htout, "$_\n"); }
		if ($_ eq $htfooter) { $start = 0; }
		if ($start == 1 && $_ =~ s/Deny from //g) {
			push(@denies, $_);
		}
	}
	if ($use_htaccess && ($action eq "add" || $action eq "remove")) {
		my $htaccess  = "# Last modified by The Guardian: " . &timeformat($date, 1) . " #\n\n";
		$htaccess    .= "@htout";
		if ($value) {
			$htaccess .= "\n$htheader\n";
			foreach (@denies) {
				if ($_ ne $value) { $htaccess .= "Deny from $_\n"; }
			}
			if ($action eq "add") { $htaccess .= "Deny from $value\n"; }
			$htaccess .= "$htfooter\n";
		}
		&write_DBorFILE(0,'',".",'','htaccess',($htaccess));
	}
}

1;