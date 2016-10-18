<id>
Apache 2.4 fix for YaBB 2.7.00
</id>

<version>
0.3 alpha
</version>

<mod info>
This mod updates code in Guardian and in the .htaccess files that is deprecated in Apache 2.4.

Version History
---------------
0.1 alpha - First release - Jan 16, 2016
0.3 alpha - 2.7.0 - Sep 1, 2016

Instructions:

Apply the mod and upload (in ASCII mode):

cgi-bin/yabb2/Admin/Modlist.pm
cgi-bin/yabb2/Admin/ErrorLog.pm
cgi-bin/yabb2/Admin/GuardianAdmin.pm
cgi-bin/yabb2/Sources/Guardian.pm
cgi-bin/yabb2/Admin/.htaccess
cgi-bin/yabb2/Backup/.htaccess
cgi-bin/yabb2/Boards/.htaccess
cgi-bin/yabb2/Help/.htaccess
cgi-bin/yabb2/Languages/.htaccess
cgi-bin/yabb2/Members/.htaccess
cgi-bin/yabb2/Messages/.htaccess
cgi-bin/yabb2/Modules/.htaccess
cgi-bin/yabb2/Sources/.htaccess
cgi-bin/yabb2/Templates/.htaccess
cgi-bin/yabb2/Variables/.htaccess

Put your Forum into Maintenance Mode. Apply the Mod then go to Admin Center -> GuardianSettings. All your blocked IPs should appear in the blocked IP section. Save Guardian Settings to rewrite the .htaccess file in the yabb2 folder.

</mod info>

<author>
Dandello
</author>

<homepage>
http://www.yabbforumsoftware.com/
</homepage>

<edit file>
Admin/ModList.pm
</edit file>

<search for>
### END BOARDMOD ANCHOR ###
</search for>

<add before>
    my $apache24_a = q~Apache 2.4 fix for YaBB 2.7.00|Dandello|This mod updates code in Guardian that is deprecated in Apache 2.4.|0.2 alpha|09/01/15~;
    push @installed_mods, $apache24_a;
</add before>

<edit file>
Admin/ErrorLog.pm
</edit file>

<search for>
        if ( $start == 1 && $ln =~ s/Deny from //gsm ) {
</search for>

<replace>
        if ( $start == 1 && ($ln =~ s/Deny from //gsm || $ln =~ s/Require not ip //gsm) ) {
</replace>

<search for>
                    $prhta .= "Deny from $ln\n";
</search for>

<replace>
                    $prhta .= "Require not ip $ln\n";
</replace>

<edit file>
Admin/GuardianAdmin.pm
</edit file>

<search for>
        if ( $start == 1 && $chk =~ s/Deny from //gsm ) {
</search for>

<replace>
        if ( $start == 1 && ($chk =~ s/Deny from //gsm || $chk =~ s/Require not ip //gsm) ) {
</replace>

<search for>
                    $prhta .= "Deny from $_\n";
</search for>

<replace>
                    $prhta .= "Require not ip $_\n";
</replace>

<edit file>
Sources/Guardian.pm
</edit file>

<search for>
        if ( $start == 1 && $i =~ s/Deny from //gsm ) {
</search for>

<replace>
        if ( $start == 1 && $_ =~ s/Require not ip //gsm ) {
</replace>

<search for>
                $prhta .= "Deny from $_\n";
</search for>

<replace>
                $prhta .= "Require not ip $_\n";
</replace>

<edit file>
Admin/.htaccess
</edit file>

<search for>
order allow,deny
deny from all
</search for>

<replace>
Require all denied
</replace>

<edit file>
Boards/.htaccess
</edit file>

<search for>
order allow,deny
deny from all
</search for>

<replace>
Require all denied
</replace>

<edit file>
Help/.htaccess
</edit file>

<search for>
order allow,deny
deny from all
</search for>

<replace>
Require all denied
</replace>

<edit file>
Languages/.htaccess
</edit file>

<search for>
order allow,deny
deny from all
</search for>

<replace>
Require all denied
</replace>

<edit file>
Members/.htaccess
</edit file>

<search for>
order allow,deny
deny from all
</search for>

<replace>
Require all denied
</replace>

<edit file>
Messages/.htaccess
</edit file>

<search for>
order allow,deny
deny from all
</search for>

<replace>
Require all denied
</replace>

<edit file>
Modules/.htaccess
</edit file>

<search for>
order allow,deny
deny from all
</search for>

<replace>
Require all denied
</replace>

<edit file>
Sources/.htaccess
</edit file>

<search for>
<Limit GET>
order allow,deny
deny from all
</Limit>
</search for>

<replace>
<LimitExcept POST>
Require all granted
</LimitExcept>
</replace>

<edit file>
Templates/.htaccess
</edit file>

<search for>
order allow,deny
deny from all
</search for>

<replace>
Require all denied
</replace>

<edit file>
Variables/.htaccess
</edit file>

<search for>
order allow,deny
deny from all
</search for>

<replace>
Require all denied
</replace>