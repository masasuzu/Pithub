use FindBin;
use lib "$FindBin::Bin/../lib";
use Pithub::Test;
use Test::Most;

BEGIN {
    use_ok('Pithub::Gists');
}

my $obj = Pithub::Test->create('Pithub::Gists');

isa_ok $obj, 'Pithub::Gists';

throws_ok { $obj->is_starred } qr{Missing parameter: \$gist_id}, 'No parameter';
throws_ok { $obj->is_starred(123); } qr{Access token required for: GET /gists/123/star}, 'Token required';

ok $obj->token(123), 'Token set';

{
    my $result = $obj->is_starred(123);
    is $result->request->method, 'GET', 'HTTP method';
    is $result->request->uri->path, '/gists/123/star', 'HTTP path';
    my $http_request = $result->request->http_request;
    is $http_request->content, '', 'HTTP body';
}

done_testing;