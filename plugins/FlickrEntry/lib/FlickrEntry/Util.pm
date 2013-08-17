package FlickrEntry::Util;
use strict;

sub field_sets {
    my $plugin = MT->component( 'FlickrEntry' );
    return ( { 'photo_id' => $plugin->translate( 'Photo ID' ), },
             { 'photo_url' => $plugin->translate( 'Photo URL' ), },
             { 'photo_page_url' => $plugin->translate( 'Photo Page URL' ), },
             { 'photo_thumbnail_url' => $plugin->translate( 'Thumbnail URL' ), },
             { 'photo_description' => $plugin->translate( 'Photo Description' ), },
           );
}

1;
