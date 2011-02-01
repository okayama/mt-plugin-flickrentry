package MT::FlickrEntry::Plugin;
use strict;

my $plugin = MT->component( 'FlickrEntry' );

sub _cb_tp_edit_entry {
    my ( $cb, $app, $param, $tmpl ) = @_;
    if ( my $blog = $app->blog ) {
        my $blog_id = $blog->id;
        my $scope = 'blog:' . $blog_id;
        return unless $plugin->get_config_value( 'is_active', 'blog:' . $blog_id );
        unless ( $app->param( 'reedit' ) ) {
            if ( my $photo_url = $app->param( 'photo_url' ) ) {
                $param->{ photo_url } = $photo_url;
            }
            if ( my $photo_thumbnail_url = $app->param( 'photo_thumbnail_url' ) ) {
                $param->{ photo_thumbnail_url } = $photo_thumbnail_url;
            }
            if ( my $title = $app->param( 'title' ) ) {
                $param->{ title } = $title;
            }
            if ( my $pointer_field = $tmpl->getElementById( 'title' ) ) {
                my @field_sets = ( { 'photo_thumbnail_url' => $plugin->translate( 'Thumbnail URL' ), },
                                   { 'photo_url' => $plugin->translate( 'Photo URL' ), },
                                 );
                for my $field_set ( @field_sets ) {
                    my @field_key = keys %$field_set;
                    my $field_id = $field_key[ 0 ];
                    my $field_label = $$field_set{ $field_id };
                    my $nodeset = $tmpl->createElement( 'app:setting', { id => $field_id,
                                                                         label => $field_label,
                                                                         label_class => 'top_level',
                                                                         required => 0,
                                                                       }
                                                      );
                    my $innerHTML = <<MTML;
<input type="text" name="$field_id" id="$field_id" value="<mt:var name="$field_id">" class="full-width text" />
MTML
                    $nodeset->innerHTML( $innerHTML );
                    $tmpl->insertAfter( $nodeset, $pointer_field );
                }
            }
        }
    }
}

1;
