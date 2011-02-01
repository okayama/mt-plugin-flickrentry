package MT::FlickrEntry::Tags;
use strict;

my $plugin = MT->component( 'FlickrEntry' );

sub _hdlr_entry_photo_url {
    my ( $ctx, $args, $cond ) = @_;
    my $entry = $ctx->stash( 'entry' ) or return $ctx->_no_entry_error( $ctx->stash( 'tag' ) );
    return $entry->photo_url || '';
}

sub _hdlr_entry_photo_thumbnail_url {
    my ( $ctx, $args, $cond ) = @_;
    my $entry = $ctx->stash( 'entry' ) or return $ctx->_no_entry_error( $ctx->stash( 'tag' ) );
    return $entry->photo_thumbnail_url || '';
}

1;
