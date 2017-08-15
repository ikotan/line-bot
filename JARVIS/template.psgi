use strict;
use warnings;

use Plack::Request;
use LINE::Bot::API;
use LINE::Bot::API::Builder::TemplateMessage;
use LINE::Bot::API::Builder::SendMessage;

use utf8;
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
    if ($event->is_postback_event) {
      warn Dumper $event->postback_data;
    }

    if ($event->is_user_event && $event->is_message_event && $event->is_text_message) {
      my $buttion = LINE::Bot::API::Builder::TemplateMessage->new_buttons(
        alt_text => 'this is a buttons template',
        image_url => 'https://soan.jp/wp-content/uploads/2015/07/385480_428318143878717_620103757_n.jpg',
        title => 'アベンジャーズ',
        text => 'アベンジャーズシリーズ'
      )->add_postback_action(
        label => 'like',
        data => 'like like'
      )->add_uri_action(
        label => 'uri',
        uri => 'http://marvel.disney.co.jp/'
      );
      # )->add_message_action(
        # label => 'like',
        # text => 'like like'

      my $messages = LINE::Bot::API::Builder::SendMessage->new()
        ->add_template($buttion->build);

      my $res = $bot->reply_message($event->reply_token, $messages->build);
    }
  }

  return [200, [], ["OK"]];
}
