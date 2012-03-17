#!/usr/bin/env perl
use Mojolicious::Lite;
BEGIN{ plugin 'Mojolicious::Plugin::EventSource' }

my $foi = {};

get '/vai' => sub{
   my $self = shift;
   $foi = {};
   $self->render( text => 1 ) ;
};

get '/' => 'index';

event_source '/events' => sub {
  my $self = shift;
  print $self->tx, $/;

  my $id = Mojo::IOLoop->recurring(1 => sub {
    my $pips = int(rand 6) + 1;
    if(not exists $foi->{$self->tx}) {
       $self->emit("dice", $pips);
       $foi->{$self->tx}++;
    }
  });
  $self->on(finish => sub { print $/ x 3, "finish!!!", $/ x 3, Mojo::IOLoop->drop($id) });
};

app->start;
__DATA__

@@ index.html.ep
<!doctype html><html>
  <head><title>Roll The Dice</title></head>
  <body>
    <script>
      var events = new EventSource('<%= url_for 'events' %>');

      // Subscribe to "dice" event
      events.addEventListener('dice', function(event) {
        document.body.innerHTML += event.data + '<br/>';
      }, false);
    </script>
  </body>
</html>
