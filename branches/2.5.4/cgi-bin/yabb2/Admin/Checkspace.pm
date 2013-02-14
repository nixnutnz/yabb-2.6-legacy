###############################################################################
# Checkspace.pm                                                               #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.5.4                                                  #
# Packaged:       January 1, 2013                                             #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2012 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
use CGI::Carp qw(fatalsToBrowser);
use English '-no_match_vars';
our $VERSION = '2.5.4';

$checkspacepmver = 'YaBB 2.5.4 $Revision$';
if ( $action eq 'detailedversion' ) { return 1; }

require Admin::NewSettings;

sub checkspace {
    is_admin_or_gmod();

    if ($checkspace) {

        # Free Disk Space Checking
        if ( $OSNAME =~ /Win/sm ) {
            @x = qx{DIR /-C};
            my $lastline = pop
              @x;    # should look like: 17 Directory(s), 21305790464 Bytes free
            return -1
              if $lastline !~ m/byte/ism
            ; # error trapping if output fails. The word byte should be in the line
            if ( $lastline =~ /^\s+(\d+)\s+(.+?)\s+(\d+)\s+(.+?)\n$/xsm ) {
                $FreeBytes = $3 - 100_000;
            }    # 100000 bytes reserve
            if ( $FreeBytes >= 1_073_741_824 ) {
                $yyfreespace =
                  sprintf( '%.2f', $FreeBytes / ( 1024 * 1024 * 1024 ) )
                  . ' GB';
            }
            elsif ( $FreeBytes >= 1_048_576 ) {
                $yyfreespace =
                  sprintf( '%.2f', $FreeBytes / ( 1024 * 1024 ) ) . ' MB';
            }
            else {
                $yyfreespace = sprintf( '%.2f', $FreeBytes / 1024 ) . ' KB';
            }
            @disk_space = $yyfreespace;

        }
        else {
            @disk_space = qx{df -k .};

            map { $_ =~ s/ +/  /gsm } @disk_space;
        }
        my @find = qx(find . -noleaf -type f -printf '%s-');

        $hostusername = $hostusername
          || ( split / +/sm, qx{ls -l YaBB.$yyext} )[2];
        my @quota = qx{quota -u $hostusername -v};
        $quota[0] =~ s/^ +//sm;
        $quota[0] =~ s/ /&nbsp;/gsm;
        $quota[1] =~ s/^ +//sm;
        $quota[1] =~ s/ /&nbsp;/gsm;
        my $quota_select = qq~$quota[0]<br />$quota[1]~;
        if ( $quota[2] ) {

            if ( !$enable_quota ) {
                $ds = ( split / +/sm, $disk_space[1], 2 )[0];
            }
            $quota_select .= q~<br /><select name="enable_quota_value">~;
            for my $i ( 2 .. ( @quota - 1 ) ) {
                $quota[$i] =~ s/^ +//sm;
                $quota[$i] =~ s/ +/&nbsp;&nbsp;/gsm;
                $quota_select .= qq~<option value="$i" ~
                  . ${
                    isselected(
                        $i == $enable_quota
                          || ( $ds && $quota[$i] =~ /^$ds/xsm )
                    )
                  }
                  . qq~>$quota[$i]</option>~;
            }
            $quota_select .= '</select>';
        }
    }
    @settings = (
    {
        name  => $settings_txt{'checkspace'},
        id    => 'checkspace',
        items => [
        { header => $settings_txt{'freedisk'}, },
        {
            description =>
              qq~<label for="enable_quota">$admin_txt{'quota'}</label>~,
            input_html =>
q~<input type="checkbox" name="enable_quota" id="enable_quota" value="1" ~
              . (
                !$quota[2] ? 'disabled="disabled" '
                : ${ ischecked($enable_quota) }
              )
              . q~/>~,
            name       => 'enable_quota',
            validate   => 'boolean',
            depends_on => (
                !$quota[2] ? []
                : [
                    '!enable_freespace_check', '(findfile_time==0||',
                    'findfile_time==||',       'findfile_maxsize==0||',
                    'findfile_maxsize==)'
                ]
            ),
        },
        {
            description =>
qq~<label for="enable_quota_value">$admin_txt{'quota_value'}</label>~,
            input_html => (
                $quota[2] ? $quota_select
                : q~<input type="hidden" name="enable_quota_value" id="enable_quota_value" value="0" />~
            ),
            name       => 'enable_quota_value',
            validate   => 'number,null',
            depends_on => ['enable_quota'],
        },
        {
            description =>
              qq~<label for="hostusername">$admin_txt{'quotahostuser'}</label>~,
            input_html =>
qq~<input type="text" name="hostusername" id="hostusername" size="20" value="$hostusername" />~,
            name       => 'hostusername',
            validate   => 'text,null',
            depends_on => ['enable_quota'],
        },
        {
            description =>
              qq~<label for="findfile_time">$admin_txt{'findtime'}</label>~,
            input_html =>
q~<input type="text" name="findfile_time" id="findfile_time" size="4" value="~
              . ( @find ? qq~$findfile_time"~ : '0" disabled="disabled"' )
              . qq~ /> $admin_txt{'537'}~,
            name     => 'findfile_time',
            validate => 'number,null',
            depends_on =>
              ( @find ? [ '!enable_quota', '!enable_freespace_check' ] : [] ),
        },
        {
            description =>
              qq~<label for="findfile_root">$admin_txt{'findroot'}</label>~,
            input_html =>
qq~<input type="text" name="findfile_root" id="findfile_root" size="40" value="$findfile_root" ~
              . ( @find ? q{} : 'disabled="disabled" ' ) . q~/>~,
            name     => 'findfile_root',
            validate => 'text,null',
            depends_on =>
              ( @find ? [ '!enable_quota', '!enable_freespace_check' ] : [] ),
        },
        {
            description =>
              qq~<label for="findfile_maxsize">$admin_txt{'findmax'}</label>~,
            input_html =>
qq~<input type="text" name="findfile_maxsize" id="findfile_maxsize" size="10" value="$findfile_maxsize" ~
              . ( @find ? q{} : 'disabled="disabled" ' )
              . q~/> MB~,
            name     => 'findfile_maxsize',
            validate => 'number,null',
            depends_on =>
              ( @find ? [ '!enable_quota', '!enable_freespace_check' ] : [] ),
        },
        {
            description =>
qq~<label for="enable_freespace_check">$admin_txt{'diskspacecheck'}</label>~,
            input_html =>
qq~<input type="checkbox" name="enable_freespace_check" id="enable_freespace_check" value="1" ${ischecked($enable_freespace_check)}/><pre>@disk_space</pre>~,
            name       => 'enable_freespace_check',
            validate   => 'boolean',
            depends_on => [
                '!enable_quota',     '(findfile_time==0||',
                'findfile_time==||', 'findfile_maxsize==0||',
                'findfile_maxsize==)'
            ],
        },
        ],
        },
    );
chsettings();
    $yytitle     = 'checkspace';
    $action_area = 'checkspace';
    exit;
}


sub chsettings {
    is_admin_or_gmod();

    $yytitle = $admin_txt{'checkspclabel'};
    $page = 'checkspace';

    my @requireorder;    # an array for the correct order of the requirements
    my %requirements;    # a hash that says "Y is required by X"

    $yymain .= qq~
    <a id="top"></a>
    <div class="bordercolor rightboxdiv">
        <table class="cs_thin pad_4px">
                <tr>
                    <td class="titlebg">
         <b>$yytitle</b>
       </td>
               </tr><tr>
                <td class="windowbg2 padd_8_12px">
        $admin_txt{'347'}
       </td>
     </tr>
  </table>
  </div>
  <form action="$adminurl?action=newsettings2;page=$page" onsubmit="undisableAll(this);" method="post" accept-charset="$yycharset">
~;
    foreach my $tab (@settings) {
        $yymain .= qq~
    <div class="bordercolor rightboxdiv">
        <table class="section" style="border-collapse:separate; border-spacing: 1px;" id="tab_$tab->{'id'}">
            <col class=" w_50pc" />
     <tr>
                <td class="titlebg padd_4px" colspan="2">
                    <a id="tab_$tab->{'id'}"></a><img src="$imagesdir/preferences.gif" alt="" /> <b>$tab->{'name'}</b>
       </td>
     </tr>~;

        foreach my $item ( @{ $tab->{'items'} } ) {
            if ( $item->{'header'} ) {
                $yymain .= qq~<tr>
                <td class="catbg padd_4px" colspan="2">
         <span class="small">$item->{'header'}</span>
       </td>
     </tr>~;
            }
            elsif ( $item->{'two_rows'} && $item->{'input_html'} ) {
                $yymain .= qq~<tr>
                <td class="windowbg2 padd_4px" colspan="2">
         $item->{'description'}
       </td>
            </tr><tr>
                <td class="windowbg2 padd_4px" colspan="2">
         $item->{'input_html'}
       </td>
     </tr>~;
            }
            elsif ( $item->{'input_html'} ) {
                $yymain .= qq~<tr>
                <td class="windowbg2 vtop padd_4px">
         $item->{'description'}
       </td>
                <td class="windowbg2 vtop padd_4px">
         $item->{'input_html'}
       </td>
     </tr>~;
            }

            # Handle settings that require other settings
            if ( $item->{'depends_on'} && $item->{'name'} ) {
                foreach my $require ( @{ $item->{'depends_on'} } ) {

# This is somewhat messy, but it works well.
# We strip off the possible options: inverse, equal, and not equal
# Then we attach those to this current option in the detailed string for requirements
# While this data does not really belong with the value, it transfers nicely.
# We then remove it and reuse it later.
                    my ( $inverse, $realname, $remainder ) =
                      $require =~ m{(\(?\!?)(\w+)(.*)}xsm;
                    if ( !$requirements{$realname} ) {
                        push @requireorder, $realname;
                    }
                    push
                      @{ $requirements{$realname} },
                      $inverse . $item->{'name'} . $remainder;
                }
            }
        }

        $yymain .= q~
   </table>
  </div>~;
    }

    my %requirejs;

    my $dependicies = q{};
    my $onloadevents;
    foreach my $ritem (@requireorder) {
        $dependicies .= qq~
    function handleDependent_$ritem() {
        var isChecked = document.getElementsByName("$ritem")[0].checked;
        var itemValue = document.getElementsByName("$ritem")[0].value;\n~;

        foreach my $require ( @{ $requirements{$ritem} } ) {

            # && or ||, ( and )
            my $AndOr = $require =~ s/\)//xsm ? ')' : q{};
            $AndOr .= $require =~ s/\|\|//xsm ? ' ||' : ' &&';
            my $C = $require =~ s/\(//xsm ? '(' : q{};

            # Is false
            if ( $require =~ s/^\!//xsm ) {
                $requirejs{$require} .=
qq~$C\!document.getElementsByName("$ritem")[0].checked$AndOr ~;
            }

            # Is equal to
            elsif ( $require =~ s/\=\=(.*)$//xsm ) {
                $requirejs{$require} .=
qq~$C\document.getElementsByName("$ritem")[0].value == '$1'$AndOr ~;
            }

            # Is not equal to
            elsif ( $require =~ s/\!\=(.*)$//xsm ) {
                $requirejs{$require} .=
qq~$C\document.getElementsByName("$ritem")[0].value != '$1'$AndOr ~;
            }

            # Is true
            else {
                $requirejs{$require} .=
                  qq~$C\document.getElementsByName("$ritem")[0].checked$AndOr ~;
            }
            $dependicies .= qq~     checkDependent("$require");\n~;
        }
        $dependicies .= qq~ };
    document.getElementsByName("$ritem")[0].onclick = handleDependent_$ritem;
    document.getElementsByName("$ritem")[0].onkeyup = handleDependent_$ritem;
~;
        $onloadevents .= qq~handleDependent_$ritem(); ~;
    }

    # Hidden "feature": jump directly to a tab by default via the URL bar.
    $INFO{'tab'} =~ s/\W//gxsm;
    $default_tab = $INFO{'tab'} || $settings[0]->{'id'};
    $yymain .= qq~
<div class="bordercolor rightboxdiv" style="margin: 1em auto 0 0">
    <table class="cs_thin pad_4px">
        <tr>
            <td class="titlebg" colspan="2">
                <img src="$imagesdir/preferences.gif" alt=""  /> <b>$admin_txt{'10'}</b>
       </td>
        </tr><tr>
            <td class="catbg center pad_4px" colspan="2">
         <input class="button" type="submit" value="$admin_txt{'10'}" />
       </td>
     </tr>
   </table>
  </div>
  </form>
  <script type="text/javascript">
    function getElementsByClass(searchClass,node,tag) {
        var classElements = new Array();
        if ( node == null )
            node = document;
        if ( tag == null )
            tag = '*';
        var els = node.getElementsByTagName(tag);
        var elsLen = els.length;
        var pattern = new RegExp('(^|\\s)'+searchClass+'(\\s|\$)');
        for (i = 0, j = 0; i < elsLen; i++) {
            if ( pattern.test(els[i].className) ) {
                classElements[j] = els[i];
                j++;
            }
        }
        return classElements;
    }
    function changeToTab(tab) {
        var elements = getElementsByClass('section');
        var i;
        for(i = 0; i < elements.length; i++) {
            if(elements[i].id == 'tab_' + tab) {
                elements[i].style.display = '';
            }
            else {
                elements[i].style.display = 'none';
            }
        }
        var elm = getElementsByClass('curtab')[0];
        if(elm) {
            elm.className = '';
        }
        document.getElementById('button_' + tab).className = 'curtab';
    }
    var removables = getElementsByClass('js_remove_me');
    var i;
    for(i = 0; i < removables.length; i++) {
        removables[i].innerHTML = '';
    }
    changeToTab('$default_tab'); // Focus default tab
    function checkDependent(eid) {
        var elm = document.getElementsByName(eid)[0];\n~;

    # Loop through each item that depends on something else
    foreach my $name ( keys %requirejs ) {
        my $logic = $requirejs{$name};
        $logic =~ s/ (&&|\|\|) $//sm;
        $yymain .= qq~
        if (eid == "$name" && ($logic)) {
            elm.disabled = false;
        } else if (eid == "$name") {
            elm.disabled = true;
        }\n~;
    }

    $yymain .= qq~
    }
$dependicies
    window.onload = function(){ $onloadevents};
    function undisableAll(node) {
        var elements = document.getElementsByTagName("input");
        for(var i = 0; i < elements.length; i++) {
            elements[i].disabled = false;
        }
        elements = document.getElementsByTagName("textarea");
        for( i = 0; i < elements.length; i++) {
            elements[i].disabled = false;
        }
        elements = document.getElementsByTagName("select");
        for( i = 0; i < elements.length; i++) {
            elements[i].disabled = false;
        }
    }
  // -->
  </script>~;

    $action_area = "newsettings;page=$page";
    AdminTemplate();
    return;
}

sub SaveSettings {
    my %settings = @_;

    if ($checkspace) {
        if (   $settings{'enable_quota'}
            && $settings{'enable_quota_value'} > 1
            && $settings{'hostusername'} )
        {
            $settings{'enable_quota'}     = $settings{'enable_quota_value'};
            $settings{'findfile_maxsize'} = 0;
            $settings{'enable_freespace_check'} = 0;
        }
        elsif (-d "$settings{'findfile_root'}"
            && $settings{'findfile_maxsize'} > 0
            && !$settings{'enable_freespace_check'} )
        {
            $findfile_space = '1<>0';
            $settings{'enable_quota'} = 0;
        }
        elsif ( $settings{'enable_freespace_check'} ) {
            $settings{'findfile_maxsize'} = 0;
            $settings{'enable_quota'}     = 0;
        }
        elsif (!-d "$settings{'findfile_root'}"
            || !$settings{'findfile_maxsize'} )
        {
            $settings{'findfile_time'}    = 0;
            $settings{'findfile_maxsize'} = 0;
        }
    }
    else {
        $settings{'findfile_maxsize'}       = 0;
        $settings{'enable_freespace_check'} = 0;
        $findfile_space                     = '1<>0';
        $settings{'enable_quota'}           = 0;
        $settings{'findfile_time'}          = 0;
    }

    SaveSettingsTo( 'Settings.pm', %settings );
    return;
}

1;
