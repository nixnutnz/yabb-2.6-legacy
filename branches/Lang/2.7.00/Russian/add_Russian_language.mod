<id>
Add Russian Language for YaBB 2.7.00
</id>

<version>
0.3
</version>

<mod info>
This mod adds the Russian Language Pack.

Version History
---------------
0.2 - First release - March 18, 2016
0.3 - Updated - Aug 11, 2017

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
    my $add_russian = q~Add Russian Language for YaBB 2.7.00|Dandello|This mod adds the Russian Language Pack.|0.3|08/11/2017~;
    push @installed_mods, $add_russian;
</add before>

<edit file>
Admin/YaBMod.pm
</edit file>

<search for>
if (@yabmodpmmods) {
</search for>

<add before>
push @yabmodpmmods, 'Russian Lang';
</add before>

<search for>
## src mod hook ##
</search for>

<add before>
                push @srcfolders, 'Languages/Russian/', 'Languages/Russian/Mods/';
</add before>

<edit file>
Languages/Lang.lng
</edit file>

<search for>
1;
</search for>

<add before>
$lngs{'Russian'} = 'русский язык';
</add before>

