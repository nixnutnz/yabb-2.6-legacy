<id>
Add Dutch Language for YaBB 2.7.00
</id>

<version>
0.2
</version>

<mod info>
This mod adds the Dutch Dutch Language Pack.

Version History
---------------
0.1 - First release - March 31, 2017
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
    my $add_dutch = q~Add Dutch Language for YaBB 2.7.00|Dandello|This mod adds the internal references for the Dutch Language Pack.|0.1|3/31/2017~;
    push @installed_mods, $add_dutch;
</add before>

<edit file>
Admin/Admin.pm
</edit file>

<search for>
if (@adminpmmods) {
</search for>

<add before>
push @adminpmmods, 'Dutch Lang';
</add before>

<search for>
    if ( -e './Languages/English/Convert.lng' )  { unlink './Languages/English/Convert.lng'; }
</search for>

<add after>
    if ( -e './Languages/Dutch/Convert.lng' )  { unlink './Languages/Dutch/Convert.lng'; }
</add after>

<edit file>
Admin/YaBMod.pm
</edit file>

<search for>
if (@yabmodpmmods) {
</search for>

<add before>
push @yabmodpmmods, 'Dutch Lang';
</add before>

<search for>
## src mod hook ##
</search for>

<add before>
                push @srcfolders, 'Languages/Dutch/', 'Languages/Dutch/Mods/';
</add before>

<edit file>
Languages/Lang.lng
</edit file>

<search for>
1;
</search for>

<add before>
$lngs{'Dutch'} = 'Nederlands';
</add before>

