<id>
Add Russian Language for YaBB 2.7.00
</id>

<version>
0.1
</version>

<mod info>
This mod adds the internal references for the Russian Language Pack.
Note: The Russian Language pack must be uploaded to the Languages folder first. 

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
    my $add_russian = q~Add Russian Language for YaBB 2.7.00|Dandello|This mod adds the internal references for the German Language Pack.|0.1|2/17/2016~;
    push @installed_mods, $add_russian;
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

