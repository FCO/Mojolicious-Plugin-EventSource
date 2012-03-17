package Mojolicious::Plugin::EventSource;
use Mojo::Base 'Mojolicious::Plugin';

sub register {
   my $self = shift;
   my $app  = shift;
   my $conf = shift;
   $conf->{ timeout } ||= 300;
   $app->routes->add_shortcut('event_source' => sub {
      my $self = shift;
      my @pars = map {
         if(ref $_ eq "CODE") {
            my $copy = $_;
            $_ = sub {
               my $self = shift;
               Mojo::IOLoop->stream($self->tx->connection)->timeout($conf->{ timeout });
               $self->res->headers->content_type('text/event-stream');
               $self->$copy(@_);
            };
         }
         $_;
      } @_;

      $app->routes->get( @_, "" );
   });
   
   *{ main::event_source } = sub { $app->routes->event_source( @_ ) };
      
   $app->helper( 'emit' => sub {
      my $self  = shift;
      my $event = shift;
      my $data  = shift;
   
      $self->write("event:$event\ndata: $data\n\n");
   } );
}

42
