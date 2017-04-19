<id>
Add German Language for YaBB 2.7.00
</id>

<version>
0.2
</version>

<mod info>
This mod adds the internal references for the German Language Pack.
Note: The German Language pack must be uploaded first.

Version History
---------------
0.1 - First release - Feb 18, 2016

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
    my $add_german = q~Add German Language for YaBB 2.7.00|Dandello|This mod adds the internal references for the German Language Pack.|0.2|3/09/2017~;
    push @installed_mods, $add_german;
</add before>

<edit file>
Admin/YaBMod.pm
</edit file>

<search for>
if (@yabmodpmmods) {
</search for>

<add before>
push @yabmodpmmods, 'German Lang';
</add before>

<search for>
## src mod hook ##
</search for>

<add before>
                push @srcfolders, 'Languages/German/', 'Languages/German/Mods/';
</add before>

<edit file>
Languages/Lang.lng
</edit file>

<search for>
1;
</search for>

<add before>
$lngs{'German'} = 'Deutsch';
</add before>

