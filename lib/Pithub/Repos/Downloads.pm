package Pithub::Repos::Downloads;

# ABSTRACT: Github v3 Repo Downloads API

use Moose;
use Carp qw(croak);
use HTTP::Request::Common qw(POST);
use namespace::autoclean;
extends 'Pithub::Base';

=method create

=over

=item *

Creating a new download is a two step process. You must first
create a new download resource using this call here. After
that you take the return L<Pithub::Result> object and call
L</upload> to upload the file to Amazon S3.

    POST /repos/:user/:repo/downloads

Examples:

    $result = $p->repos->downloads->create(
        user => 'plu',
        repo => 'Pithub',
        data => {
            name         => 'new_file.jpg',
            size         => 114034,
            description  => 'Latest release',
            content_type => 'text/plain',
        },
    );

    $p->repos->downloads->upload(
        result => $result,
        file   => '/path/to/file',
    );

=back

=cut

sub create {
    my ( $self, %args ) = @_;
    croak 'Missing key in parameters: data (hashref)' unless ref $args{data} eq 'HASH';
    $self->_validate_user_repo_args( \%args );
    return $self->request( POST => sprintf( '/repos/%s/%s/downloads', $args{user}, $args{repo} ), $args{data} );
}

=method delete

=over

=item *

Delete a download

    DELETE /repos/:user/:repo/downloads/:id

Examples:

    $result = $p->repos->downloads->delete(
        user        => 'plu',
        repo        => 'Pithub',
        download_id => 1,
    );

=back

=cut

sub delete {
    my ( $self, %args ) = @_;
    croak 'Missing key in parameters: download_id' unless $args{download_id};
    $self->_validate_user_repo_args( \%args );
    return $self->request( DELETE => sprintf( '/repos/%s/%s/downloads/%s', $args{user}, $args{repo}, $args{download_id} ) );
}

=method get

=over

=item *

Get a single download

    GET /repos/:user/:repo/downloads/:id

Examples:

    $result = $p->repos->downloads->get(
        user        => 'plu',
        repo        => 'Pithub',
        download_id => 1,
    );

=back

=cut

sub get {
    my ( $self, %args ) = @_;
    croak 'Missing key in parameters: download_id' unless $args{download_id};
    $self->_validate_user_repo_args( \%args );
    return $self->request( GET => sprintf( '/repos/%s/%s/downloads/%s', $args{user}, $args{repo}, $args{download_id} ) );
}

=method list

=over

=item *

List downloads for a repository

    GET /repos/:user/:repo/downloads

Examples:

    $result = $p->repos->downloads->list(
        user => 'plu',
        repo => 'Pithub',
    );

=back

=cut

sub list {
    my ( $self, %args ) = @_;
    $self->_validate_user_repo_args( \%args );
    return $self->request( GET => sprintf( '/repos/%s/%s/downloads', $args{user}, $args{repo} ) );
}

=method upload

=over

=item *

Upload a file to Amazon S3. See also: L</create>. This will use
the C<< ua >> attribute's C<< request >> method to do a POST
request to Amazon S3. It requires the L<Pithub::Result> object
of a L</create> call to get the necessary data for S3 API call.
This method returns an L<HTTP::Response> object directly, not
a L<Pithub::Result> object (like all other methods do)! If the
upload was successful the status will be C<< 201 >>.

=back

=cut

sub upload {
    my ( $self, %args ) = @_;
    croak 'Missing key in parameters: result (Pithub::Result object)' unless ref $args{result} eq 'Pithub::Result';
    croak 'Missing key in parameters: file' unless $args{file};
    my $result = $args{result}->content;
    foreach my $key (qw(path acl name accesskeyid policy signature mime_type)) {
        croak "Missing key in Pithub::Result content: ${key}" unless grep $_ eq $key, keys %$result;
    }
    my %data = (
        Content_Type => 'form-data',
        Content      => [
            'key'                   => $result->{path},
            'acl'                   => $result->{acl},
            'success_action_status' => 201,
            'Filename'              => $result->{name},
            'AWSAccessKeyId'        => $result->{accesskeyid},
            'Policy'                => $result->{policy},
            'Signature'             => $result->{signature},
            'Content-Type'          => $result->{mime_type},
            'file'                  => [ $args{file} ],
        ],
    );
    my $request = POST $result->{s3_url}, %data;
    return $self->ua->request($request);
}

__PACKAGE__->meta->make_immutable;

1;
