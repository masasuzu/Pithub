package Pithub::GitData::Blobs;

# ABSTRACT: Github v3 Git Data Blobs API

use Moose;
use Carp qw(croak);
use namespace::autoclean;
extends 'Pithub::Base';

=method create

=over

=item *

Create a Blob

    POST /repos/:user/:repo/git/blobs

Examples:

    my $b = Pithub::GitData::Blobs->new;
    my $result = $b->create(
        user => 'plu',
        repo => 'Pithub',
        data => {
            content  => 'Content of the blob',
            encoding => 'utf-8',
        }
    );

=back

=cut

sub create {
    my ( $self, %args ) = @_;
    croak 'Missing key in parameters: data (hashref)' unless ref $args{data} eq 'HASH';
    $self->_validate_user_repo_args( \%args );
    return $self->request(
        method => 'POST',
        path   => sprintf( '/repos/%s/%s/git/blobs', delete $args{user}, delete $args{repo} ),
        %args,
    );
}

=method get

=over

=item *

Get a Blob

    GET /repos/:user/:repo/git/blobs/:sha

Examples:

    my $b = Pithub::GitData::Blobs->new;
    my $result = $b->get(
        user => 'plu',
        repo => 'Pithub',
        sha  => 'df21b2660fb6',
    );

=back

=cut

sub get {
    my ( $self, %args ) = @_;
    croak 'Missing key in parameters: sha' unless $args{sha};
    $self->_validate_user_repo_args( \%args );
    return $self->request(
        method => 'GET',
        path   => sprintf( '/repos/%s/%s/git/blobs/%s', delete $args{user}, delete $args{repo}, delete $args{sha} ),
        %args,
    );
}

__PACKAGE__->meta->make_immutable;

1;
