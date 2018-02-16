<id>
Apache 2.4 fix for YaBB 2.7.00
</id>

<version>
0.4 alpha
</version>

<mod info>
This mod updates code in Guardian and in the .htaccess files that is deprecated in Apache 2.4.

Version History
---------------
0.1 alpha - First release - Jan 16, 2016
0.3 alpha - 2.7.0 - Sep 1, 2016
0.4 alpha - 2.7.0 - Feb 15, 2018

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
    my $apache24_a = q~Apache 2.4 fix for YaBB 2.7.00|Dandello|This mod updates code in Guardian that is deprecated in Apache 2.4.|0.4 alpha|02/15/18~;
    push @installed_mods, $apache24_a;
</add before>

<edit file>
Admin/GuardianAdmin.pm
</edit file>

<search for>
if (@guardianadminpmmods) {
</search for>

<add before>
push @guardianadminpmmods, 'Apache 2.4 fix';
</add before>

<search for>
    my $htheader = q~<Files YaBB*>~;
    my $htfooter = q~</Files>~;
</search for>

<add after>
    my $htheaderb = q~<RequireAll>~;
    my $htheaderc = q~Require all granted~;
    my $htfootera = q~</RequireAll>~;
</add after>

<search for>
        if ( $chk =~ s/\QDeny from \E//gxsm ) {
</search for>

<replace>
        if (   $chk =~ s/\QDeny from \E//gxsm
            || $chk =~ s/\QRequire not ip \E//gxsm
            || $chk =~ s/\QRequire not host \E//gxsm )
        {
</replace>

<search for>
        elsif ($chk ne $htheader
            && $chk !~ m/\x23/xsm
            && $chk ne q{}
            && $chk ne $htfooter )
        {
</search for>

<replace>
        elsif ($chk ne $htheader
            && $chk ne $htheaderb
            && $chk ne $htheaderc
            && $chk !~ m/\x23/xsm
            && $chk ne q{}
            && $chk ne $htfootera
            && $chk ne $htfooter )
        {
</replace>

<search for>
        $prhta .= "\n$htheader\n";
</search for>

<replace>
        $prhta .= "\n$htheader\n$htheaderb\n$htheaderc\n";
</replace>

<search for>
                    else { $prhta .= "Deny from $ln\n"; }
</search for>

<replace>
                    else { $prhta .= "Require not host $ln\n"; }
</replace>

<search for>
                else { $prhta .= "Deny from $ln\n"; }
</search for>

<replace>
                else { $prhta .= "Require not ip $ln\n"; }
</replace>

<search for>
        $prhta .= "$htfooter\n";
</search for>

<replace>
        $prhta .= "$htfootera\n$htfooter\n";
</replace>

<edit file>
Sources/Subs.pm
</edit file>

<search for>
if (@subspmmods) {
</search for>

<add before>
push @subspmmods, 'Apache 2.4 fix';
</add before>

<search for>
    my $htheader = q~<Files YaBB*>~;
    my $htfooter = q~</Files>~;
</search for>

<add after>
    my $htheaderb = q~<RequireAll>~;
    my $htheaderc = q~Require all granted~;
    my $htfootera = q~</RequireAll>~;
</add after>

<search for>
        if ( $chk =~ m/\QDeny from \E/gxsm ) {
</search for>

<replace>
        if (   $chk =~ /\QRequire not ip \E/xsm
            || $chk =~ /\QRequire not host \E/xsm )
        {
</replace>

<search for>
    $value = "Deny from $value";
</search for>

<replace>
    $value = "Require not ip $value";
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