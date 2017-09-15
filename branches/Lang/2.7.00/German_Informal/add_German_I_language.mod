<id>
Add German Informal Language for YaBB 2.7.00
</id>

<version>
0.3
</version>

<mod info>
This mod adds the 2.7 German Informal Language Pack.

Version History
---------------
0.1 - First release - Sep 15, 2017

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
    my $add_german_i = q~Add German Informal Language for YaBB 2.7.00|Dandello|This mod adds the German Informal Language Pack.|0.1|9/15/2017~;
    push @installed_mods, $add_german_i;
</add before>

<edit file>
Admin/Admin.pm
</edit file>

<search for>
if (@adminpmmods) {
</search for>

<add before>
push @adminpmmods, 'German Informal Lang';
</add before>

<search for>
    if ( -e './Languages/English/Convert.lng' )  { unlink './Languages/English/Convert.lng'; }
</search for>

<add after>
    if ( -e './Languages/German_Informal/Convert.lng' )  { unlink './Languages/German_Informal/Convert.lng'; }
</add after>

<edit file>
Admin/YaBMod.pm
</edit file>

<search for>
if (@yabmodpmmods) {
</search for>

<add before>
push @yabmodpmmods, 'German Informal Lang';
</add before>

<search for>
## src mod hook ##
</search for>

<add before>
                push @srcfolders, 'Languages/German_Informal/', 'Languages/German_Informal/Mods/';
</add before>

<edit file>
Languages/Lang.lng
</edit file>

<search for>
1;
</search for>

<add before>
$lngs{'German_Informal'} = 'Deutsch Informal';
</add before>
