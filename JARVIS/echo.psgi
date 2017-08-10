use strict;
use warnings;

use Plack::Request;
use LINE::Bot::API;
use LINE::Bot::API::Builder::SendMessage;

use Data::Dumper;

my $bot = LINE::Bot::API->new(
  channel_secret => $ENV{LINE_API_SECRET},
  channel_access_token => $ENV{LINE_API_ACCESS_TOKEN}
);

sub {
  my $req = Plack::Request->new(shift);

  unless ($bot->validate_signature($req->content, $req->header('X-Line-Signature'))) {
    return [200, [], ['bad request']];
  }

  my $events = $bot->parse_events_from_json($req->content);

  warn Dumper $events;

  for my $event (@{$events}) {
    if ($event->is_user_event && $event->is_message_event && $event->is_text_message) {
      my $messages = LINE::Bot::API::Builder::SendMessage->new->add_text( text => $event->text );
      my $res = $bot->reply_message($event->reply_token, $messages->build);
    }
  }

  return [200, [], ["OK"]];
}

