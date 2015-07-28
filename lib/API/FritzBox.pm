package API::FritzBox;
# ABSTRACT: API interface to FritzBox devices
use Moose;
use MooseX::Params::Validate;
use MooseX::WithCache;
use File::Spec::Functions; # catfile
use MIME::Base64;
use File::Path qw/make_path/;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Headers;
use JSON::MaybeXS;
use Digest::MD5 qw/md5_hex/;
use Log::Log4perl;
use YAML;
use URI::Encode qw/uri_encode/;
use Encode;
BEGIN { Log::Log4perl->easy_init() };
our $VERSION = 0.001;

with "MooseX::Log::Log4perl";

=head1 NAME

API::FritzBox

=head1 DESCRIPTION

Interact with FritzBox devices

=head1 ATTRIBUTES

=cut

with "MooseX::Log::Log4perl";

=over 4

=item password

Required.

=cut
has 'password' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    );

=item host

Optional.  Default: fritz.box

=cut
has 'host' => (
    is		=> 'ro',
    isa		=> 'Str',
    required	=> 1,
    default     => 'fritz.box',
    );

=item use_https

Optional.  Default: 0

=cut

has 'use_https' => (
    is		=> 'ro',
    isa		=> 'Bool',
    );

=item user_agent

Optional.  A new LWP::UserAgent will be created for you if you don't already have one you'd like to reuse.

=cut

has 'user_agent' => (
    is		=> 'ro',
    isa		=> 'LWP::UserAgent',
    required	=> 1,
    lazy	=> 1,
    builder	=> '_build_user_agent',

    );

=item loglevel

Optional.

=cut

has 'loglevel' => (
    is		=> 'rw',
    isa		=> 'Str',
    trigger     => \&_set_loglevel,
    );

has 'base_url' => (
    is		=> 'ro',
    isa		=> 'Str',
    required	=> 1,
    lazy	=> 1,
    builder	=> '_build_base_url',
    );

has 'sid' => (
    is		=> 'ro',
    isa		=> 'Str',
    required	=> 1,
    lazy	=> 1,
    builder	=> '_build_sid',
    );

sub _build_user_agent {
    my $self = shift;
    $self->log->debug( "Building zendesk useragent" );
    my $ua = LWP::UserAgent->new(
	keep_alive	=> 1
    );
   # $ua->default_headers( $self->default_headers );
    return $ua;
}

sub _build_base_url {
    my $self = shift;
    my $base_url = 'http' . ( $self->use_https ? 's' : '' ) . '://' . $self->host;
    $self->log->debug( "Base url: $base_url" );
    return $base_url;
}

sub _build_sid {
    my $self = shift;

    my $response = $self->user_agent->get( $self->base_url . '/login_sid.lua' );
    $self->log->trace( "Login (get challenge) http response:\n" . Dump( $response ) ) if $self->log->is_trace;
    my( $challenge_str ) = ( $response->decoded_content =~ /<Challenge>(\w+)/i );
    # generate a response to the challenge
    my $ch_pw = $challenge_str . '-' . $self->password;
    $ch_pw =~ s/(.)/$1 . chr(0)/eg;
    my $md5 = lc(md5_hex($ch_pw));
    my $challenge_response = $challenge_str . '-' . $md5;
    # Session ID erfragen
    $response = $self->user_agent->get( $self->base_url . '/login_sid.lua?user=&response=' . $challenge_response );
    $self->log->trace( "Login (challenge sent) http response :\n" . Dump( $response ) ) if $self->log->is_trace;

    # Session ID aus XML Daten auslesen
    my( $sid ) = ( $response->content =~ /<SID>(\w+)/i );
    $self->log->debug( "SID: $sid" );
    return $sid;
}

sub _set_loglevel {
    my( $self, $new, $old ) = @_;
    print "Setting loglevel to $new\n";
    $self->log->level( $new );
}


=back

=head1 METHODS

=over 4

=item init

Create the user agent log in (get a sid).

=cut

sub init {
    my $self = shift;
    my $ua = $self->user_agent;
    my $sid = $self->sid;
}

=item get

Get some path from the FritzBox.  e.g.
    
  my $response = $fb->get( path => '/internet/inetstat_monitor.lua?useajax=1&xhr=1&action=get_graphic' ); 

Returns the HTTP::Response object

=cut

sub get {
    my ( $self, %params ) = validated_hash(
        \@_,
        path        => { isa    => 'Str' },
    );

    my $response = $self->user_agent->get(
        $self->base_url .
        $params{path} .
        ( $params{path} =~ m/\?/ ? '&' : '?' ) .
        'sid=' . $self->sid );
    $self->log->trace( Dump( $response ) ) if $self->log->is_trace;
    return $response;
}

1;

=back

=head1 COPYRIGHT

Copyright 2015, Robin Clarke 

=head1 AUTHOR

Robin Clarke <robin@robinclarke.net>
