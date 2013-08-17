package FlickrEntry::Plugin;
use strict;

use FlickrEntry::Util;

sub _cb_tp_cfg_entry {
    my ( $cb, $app, $param, $tmpl ) = @_;
    my @field_sets = FlickrEntry::Util::field_sets();
    if ( my $entry_fields = $tmpl->getElementById( 'entry_fields' ) ) {
        my $text = $entry_fields->innerHTML;
        for my $field_set ( @field_sets ) {
            my @field_key = keys %$field_set;
            my $field_id = $field_key[ 0 ];
            my $field_label = $$field_set{ $field_id };
            $text .= <<"MTML";
<li><input type="checkbox" name="entry_custom_prefs" id="entry-prefs-$field_id" value="$field_id" <mt:if name="entry_disp_prefs_show_$field_id"> checked="checked"</mt:if> class="cb" /> <label for="entry-prefs-$field_id">$field_label</label></li>
MTML
        }
        $entry_fields->innerHTML( $text );
    }
    if ( my $page_fields = $tmpl->getElementById( 'page_fields' ) ) {
        my $text = $page_fields->innerHTML;
        for my $field_set ( @field_sets ) {
            my @field_key = keys %$field_set;
            my $field_id = $field_key[ 0 ];
            my $field_label = $$field_set{ $field_id };
            $text .= <<"MTML";
<li><input type="checkbox" name="page_custom_prefs" id="page-prefs-$field_id" value="$field_id" <mt:if name="page_disp_prefs_show_$field_id"> checked="checked"</mt:if> class="cb" /> <label for="page-prefs-$field_id">$field_label</label></li>
MTML
        }
        $page_fields->innerHTML( $text );
    }
}

sub _cb_ts_flickrentry_config_blog {
	my ( $cb, $app, $tmpl ) = @_;
	my $app_uri = $app->base . $app->uri;
	$$tmpl =~ s/\*app_uri\*/$app_uri/;
}

sub _cb_tp_edit_entry {
    my ( $cb, $app, $param, $tmpl ) = @_;
    my $plugin = MT->component( 'FlickrEntry' );
    if ( my $blog = $app->blog ) {
        my $blog_id = $blog->id;
        my $scope = 'blog:' . $blog_id;
        return unless $plugin->get_config_value( 'is_active', $scope );
        unless ( $app->param( 'reedit' ) ) {
            if ( my $pointer_field = $tmpl->getElementById( 'title' ) ) {
                my @field_sets = FlickrEntry::Util::field_sets();
                for my $field_set ( @field_sets ) {
                    my @field_key = keys %$field_set;
                    my $field_id = $field_key[ 0 ];
                    my $field_label = $$field_set{ $field_id };
                    my $innerHTML = <<MTML;
<input type="text" name="$field_id" id="$field_id" value="<mt:var name="$field_id">" class="full text" />
MTML
                    if ( $field_id =~ /_description$/ ) {
                        $innerHTML = <<MTML;
<textarea name="$field_id" id="$field_id" class="full text low"><mt:var name="$field_id"></textarea>
MTML
                    }
                    my $class = $app->param( '_type' );
                    my $perms = $app->permissions;
                    my $prefs_type = $class . '_prefs';
                    my $pref_param = $app->load_entry_prefs( { type => $class,
                                                               prefs => $perms->$prefs_type,
                                                             }
                                                           );
                    my $show_field = $pref_param ? $pref_param->{ 'disp_prefs_show_' . $field_id } : 0;
                    push( @{ $param->{ 'field_loop'} }, { 'field_id' => $field_id,
                                                          'lock_field' => '0',
                                                          'field_name' => $field_id,
                                                          'show_field' => $show_field,
                                                          'field_label' => $field_label,
                                                          'label_class' => 'top-label',
                                                          'field_html' => $innerHTML,
                                                        }
                        );
                }
            }
        }
    }
}

1;
