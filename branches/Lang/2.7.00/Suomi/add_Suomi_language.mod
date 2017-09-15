<id>
Add Suomi Language for YaBB 2.7.00
</id>

<version>
0.1
</version>

<mod info>
This mod adds the Suomi Language Pack.

Version History
---------------
0.1 - First release - March 24, 2016
0.2 - Convert.lng added

Instructions:

Apply the mod using YaBMod.
</mod info>

<author>
Dandello
</author>

<homepage>
http://www.yabbforumsoftware.com/cgi-bin/yabb2/YaBB.pl
</homepage>

<edit file>
Admin/ModList.pm
</edit file>

<search for>
### END BOARDMOD ANCHOR ###
</search for>

<add before>
    my $add_suomi = q~Add Suomi Language for YaBB 2.7.00|Dandello|This mod adds the internal references for the Suomi Language Pack.|0.2|9/15/2017~;
    push @installed_mods, $add_suomi;
</add before>

<edit file>
Admin/Admin.pm
</edit file>

<search for>
if (@adminpmmods) {
</search for>

<add before>
push @adminpmmods, 'Suomi Lang';
</add before>

<search for>
    if ( -e './Languages/English/Convert.lng' )  { unlink './Languages/English/Convert.lng'; }
</search for>

<add after>
    if ( -e './Languages/Suomi/Convert.lng' )  { unlink './Languages/Suomi/Convert.lng'; }
</add after>

<edit file>
Admin/YaBMod.pm
</edit file>

<search for>
if (@yabmodpmmods) {
</search for>

<add before>
push @yabmodpmmods, 'Suomi Lang';
</add before>

<search for>
## src mod hook ##
</search for>

<add before>
                push @srcfolders, 'Languages/Suomi/', 'Languages/Suomi/Mods/';
</add before>

<edit file>
Languages/Lang.lng
</edit file>

<search for>
1;
</search for>

<add before>
$lngs{'Suomi'} = 'Suomi';
</add before>

