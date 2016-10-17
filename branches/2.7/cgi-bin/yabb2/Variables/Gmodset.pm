### Gmod Related Settings ###

$allow_gmod_admin = 'on';
$allow_gmod_profile = 'on';
$allow_gmod_aprofile = '';
$gmod_newfile = 'on';

### Areas Gmods can Access ###

%gmod_access = (
'ext_admin' => '',

'newsettings;page=main' => '',
'newsettings;page=advanced' => 'on',
'editbots' => '',

'newsettings;page=news' => 'on',
'smilies' => 'on',
'setcensor' => 'on',
'modagreement' => 'on',
'eventcal_set' => '',
'bookmarks' => '',

'referer_control' => '',
'newsettings;page=security' => '',
'setup_guardian' => '',
'newsettings;page=antispam' => '',
'spam_questions' => '',
'honeypot' => '',
'managecats' => '',
'manageboards' => '',
'helpadmin' => 'on',
'editemailtemplates' => '',

'addmember' => '',
'viewmembers' => 'on',

'modmemgr' => '',
'mailing' => 'on',
'ipban' => 'on',
'ipban2' => 'on',
'ban_clean' => 'on',
'setreserve' => '',

'modskin' => '',
'modcss' => '',
'modtemp' => '',

'clean_log' => 'on',
'boardrecount' => '',
'rebuildmesindex' => '',
'membershiprecount' => '',
'rebuildmemlist' => '',
'rebuildmemhist' => '',
'rebuildnotifications' => '',
'deleteoldthreads' => '',
'manageattachments' => 'on',

'backup' => '',


'detailedversion' => 'on',
'stats' => 'on',
'showclicks' => 'on',
'errorlog' => 'on',

'view_reglog' => '',

'modlist' => '',
);

%gmod_access2 = (
admin => 'on',

newsettings => ['advanced','news',],
newsettings2 => ['advanced','news',],
eventcal_set2 => '',
eventcal_set3 => '',
bookmarks2 => '',
bookmarks_add => '',
bookmarks_add2 => '',
bookmarks_edit => '',
bookmarks_edit2 => '',
bookmarks_delete => '',
bookmarks_delete2 => '',
spam_questions2 => '',
spam_questions_add => '',
spam_questions_add2 => '',
spam_questions_edit => '',
spam_questions_edit2 => '',
spam_questions_delete => '',
spam_questions_delete2 => '',
honeypot2 => '',
honeypot_add => '',
honeypot_add2 => '',
honeypot_edit => '',
honeypot_edit2 => '',
honeypot_delete => '',
honeypot_delete2 => '',
deleteattachment => 'on',
manageattachments2 => 'on',
removeoldattachments => 'on',
removebigattachments => 'on',
rebuildattach => 'on',
remghostattach => 'on',
deletepmattachment => '',
managepmattachments2 => '',
removepmoldattachments => '',
removepmbigattachments => '',
rebuildpmattach => '',
remghostpmattach => '',

profile => 'on',
profile2 => 'on',
profileAdmin => '',
profileAdmin2 => '',
profileContacts => 'on',
profileContacts2 => 'on',
profileIM => 'on',
profileIM2 => 'on',
profileOptions => 'on',
profileOptions2 => 'on',

ext_edit => '',
ext_edit2 => '',
ext_create => '',
ext_reorder => '',
ext_convert => '',

myprofileAdmin => '',
myprofileAdmin2 => '',

delgroup => '',
editgroup => '',
editAddGroup2 => '',
assigned => '',
assigned2 => '',

reordercats => '',
reordercats2 => '',
modifycatorder => '',
modifycat => '',
createcat => '',
catscreen => '',
addcat => '',
addcat2 => '',

modskin => '',
modskin2 => '',
modcss => '',
modcss2 => '',
modstyle => '',
modstyle2 => '',
modtemplate2 => '',
modtemp2 => '',

modifyboard => '',
addboard => '',
addboard2 => '',
reorderboards => '',
reorderboards2 => '',
boardscreen => '',

smiliemove => 'on',
addsmilies => 'on',

addmember => '',
addmember2 => '',
ml => 'on',
deletemultimembers => '',

mailmultimembers => 'on',
mailing2 => 'on',

activate => '',
admin_descision => '',
apr_regentry => '',
del_regentry => '',
rej_regentry => '',
view_regentry => '',
clean_reglog => '',

cleanerrorlog => 'on',
deleteerror => 'on',

modagreement2 => 'on',
advsettings2 => '',
referer_control2 => '',
removeoldthreads => '',
ipban2 => 'on',
setcensor2 => 'on',
setreserve2 => '',

editbots2 => '',
);

1;
