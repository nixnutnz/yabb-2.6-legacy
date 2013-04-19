If you're testing or upgrading by overwriting the files in Admin, Sources, Languages, be sure to also replace YaBB.pl and AdminIndex.pl. And, most importantly, rename your Settings.pl to Settings.pm and Paths.pl to Paths.pm. 
We are now at the point where ONLY executable files have the .pl extension.

Also Messages/movedthreads.cgi has been renamed Messages/Movedthreads.pm (Note the capitalization.)

*NEW instructions for upgrading.* We are now using the Convert folders for *all* upgrades - even from 2.5.2. Copy your old Variables, Members, Messages and Boards folder contents into their appropriate Convert folders in 2.5.4. FixFile will double check the folder permissions and copy the files over for you - this removes some confusion as to exactly which old files need to be copied into Variables and also allows for the old settings in Settings.pl to be imported into the new Settings.pm. This is *also* in preparation for future changes in data formatting.