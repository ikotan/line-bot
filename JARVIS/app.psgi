#! /usr/bin/env perl
use strict;
use warnings;

use Plack::Request;
use LINE::Bot::API;
use LINE::Bot::API::Builder::SendMessage;

use utf8;
use Data::Dumper;

my $bot = LINE::Bot::API->new(
  channel_secret => $ENV{LINE_API_SECRET},
  channel_access_token => $ENV{LINE_API_ACCESS_TOKEN}
);

my @image_list = (
  'https://rr.img.naver.jp/mig?src=http%3A%2F%2Fpic.prepics-cdn.com%2F20110715hp7%2F19695347.jpeg&twidth=1000&theight=0&qlt=80&res_format=jpg&op=r', # アイアンマン
  'https://blog-imgs-53.fc2.com/k/u/w/kuwa98/ameijing.jpg', # スパイダーマン
  'https://blogimg.goo.ne.jp/user_image/4b/9f/a1feb8422a5992a3c29533ba3c25c9e7.png' # マイティ・ソー
);

my $app = sub {
  my $req = Plack::Request->new(shift);

  unless ($bot->validate_signature($req->content, $req->header('X-Line-Signature'))) {
    return [200, [], ['bad request']];
  }

  my $events = $bot->parse_events_from_json($req->content);

  for my $event (@{$events}) {
    my $from_id;
    if ($event->is_user_event) {
      $from_id = $event->user_id;
    }
    warn Dumper $from_id;

    if ($event->is_location_message) {
      say $event->title;
      say $event->address;
      say $event->latitude;
      say $event->longitude;
    }

    if ($event->is_user_event && $event->is_message_event && $event->is_text_message) {
      my $num = int rand(scalar @image_list);
      my $messages = LINE::Bot::API::Builder::SendMessage->new()
        ->add_text(text => $event->text)
        ->add_image(
          image_url => $image_list[$num],
          preview_url => $image_list[$num]
        )
        ->add_location(
          title => 'LINE Corporation. ',
          address => 'Hikarie Shibuya-ku Tokyo 151-0002',
          latitude => 35.6591,
          longitude => 139.7040
        );
      my $res = $bot->reply_message($event->reply_token, $messages->build);
    }

  }

  return [200, [], ["OK"]];
}

