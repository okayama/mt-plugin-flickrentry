package FlickrEntry::Tasks;
use strict;

use HTML::TreeBuilder;

sub check_flickr_photo_url {
    my $plugin = MT->component( 'FlickrEntry' );
    my @blogs = MT::Blog->load( { class => '*' } );
    for my $blog ( @blogs ) {
        my $blog_id = $blog->id;
        my $scope = 'blog:' . $blog_id;
        next unless $plugin->get_config_value( 'is_active', $scope );
        my @entries = MT::Entry->load( { blog_id => $blog_id,
                                         class => '*',
                                       }
                                     );
        for my $entry ( @entries ) {
            my $check = 0;
            my $ua = MT->new_ua;
            if ( my $photo_url = $entry->photo_url ) {
                my $req = HTTP::Request->new( GET => $photo_url );
                $req->header( 'User-Agent' => "$PLUGIN_NAME/$PLUGIN_VERSION" );
                my $res = $ua->simple_request( $req ) or return;
                unless ( $res->is_success ) {
                    $check++;
                }
            }
            if ( my $photo_thumbnail_url = $entry->photo_thumbnail_url ) {
                my $req = HTTP::Request->new( GET => $photo_thumbnail_url );
                $req->header( 'User-Agent' => "$PLUGIN_NAME/$PLUGIN_VERSION" );
                my $res = $ua->simple_request( $req ) or return;
                unless ( $res->is_success ) {
                    $check++;
                }
            }
            if ( $check ) {
                if ( my $photo_page_url = $entry->photo_page_url ) {
                    my $req = HTTP::Request->new( GET => $photo_page_url ) or return;
                    $req->header( 'User-Agent' => "$PLUGIN_NAME/$PLUGIN_VERSION" );
                    my $res = $ua->request( $req ) or return;
                    if ( $res->is_success ) {
                        my $content = $res->decoded_content;
                        my $tree = HTML::TreeBuilder->new;
                        $tree->parse( $content );                        
                        for my $meta ( $tree->find( 'link' ) ) {
                            my $rel = $meta->attr( 'rel' );
                            my $href;
                            if ( $rel && $rel eq 'image_src' ) {
                                $href = $meta->attr( 'href' );
                            }
                            if ( $href ) {
                                my $photo_url = $href;
                                $photo_url =~ s/_m/_z/;
                                $entry->photo_url( $photo_url );
                                my $photo_thumbnail_url = $href;
                                $photo_thumbnail_url =~ s/_m/_s/;
                                $entry->photo_thumbnail_url( $photo_thumbnail_url );
                                $entry->save or die $entry->errstr;
                                my $message = $plugin->translate( 'Updated link entry \'[_1]\'', encode_html( $entry->title ) );
                                MT->log( { message => $message,
                                           blog_id => $entry->blog_id,
                                         }
                                       );
                                MT->rebuild_entry( Entry => $entry );
                                last;
                            }
                        }
                    }
                }
            }
        }
    }
}

1;
