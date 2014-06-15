package Ado::Plugin::Routes;
use Mojo::Base 'Ado::Plugin';

sub register {
    my ($self, $app, $conf) = @_;
    $self->app($app);    #!Needed in $self->config!

    #Merge passed configuration with configuration
    #from  etc/ado.conf and etc/plugins/routes.conf
    $conf = {%{$self->config}, %{$conf ? $conf : {}}};
    $app->log->debug('Plugin ' . $self->name . ' configuration:' . $app->dumper($conf));

    # My magic here! :)
    push @{$app->routes->namespaces}, @{$conf->{namespaces}}
      if @{$conf->{namespaces} || []};

    #Add some conditions: Someday
#    $app->routes->add_condition(
#        require_formats => sub {
#            my ($route, $c, $captures, $formats) = @_;
#            $c->debug('$route, $c, $captures, $formats:'
#                  . $c->dumper( $route, ref $c, $captures, $formats));
#             #Carp::cluck(caller);
#            return ($c->require_formats($formats) ? 1 : undef);
#        }
#    );
    $app->load_routes($conf->{routes});

    # Rewrite urls in case we are deployed under Apache and using mod_cgi or mod_fcgi.
    # This way we have the same urls as if deployed standalone or with hypnotoad.
    # See templates/partials/apache2htaccess.ep
    $app->hook(
        before_dispatch => sub {
            state $cgi = $_[0]->req->env->{GATEWAY_INTERFACE} // '' =~ m/^CGI/;
            $_[0]->req->url->base->path($conf->{base_url_path}) if $cgi;
        }
    ) if $conf->{base_url_path};

    return $self;
}


1;


=pod

=encoding utf8

=head1 NAME

Ado::Plugin::Routes - Keep routes separately.


=head1 SYNOPSIS

  #Open $MOJO_HOME/etc/plugins/routes.conf and describe your routes
  routes     => [
        {route => '/ado-users', via => ['GET'],  
          to => 'ado-users#list',},
        {route => '/ado-users', via => ['POST'], 
          to => 'ado-users#add',},
        ...
        ],
  base_url_path =>'/'

=head1 DESCRIPTION

Ado::Plugin::Routes allows you to define your routes in a separate file
C<$MOJO_HOME/etc/plugins/routes.conf>. In the configuration file you can also use
the B<C<app>> keyword and add complex routes as you would do directly in the code.

=head1 OPTIONS

=head2 base_url_path

Base URL which will be used to construct URLs when deployed as FCGI or CGI.
Default: C<undef>.

=head2 routes

And ARAY reference describing the routes.

=head1 METHODS


L<Ado::Plugin::Routes> inherits all methods from
L<Ado::Plugin> and implements the following new ones.


=head2 register

This method is called by C<$app-E<gt>plugin>.
Registers the plugin in L<Ado> application and merges routes 
configuration from C<$MOJO_HOME/etc/ado.conf> with routes defined in
C<$MOJO_HOME/etc/plugins/routes.conf>. Routes defined in C<ado.conf>
can overwrite those defined in C<plugins/routes.conf>.

=head1 HOOKS

This plugin implements the following hooks.

=head2 before_dispatch

This hook is generated if you add to  the option C<base_url_path>
In case the application is deployed as CGI or FCGI application,
the url part containing C<ado> is removed from the base url path so the 
urls are the same as if deployed standalone or with 
L<hypnotoad|Mojo::Server::Hypnotoad>.
The configuration for Apache is expected to be generated by
L<Ado::Command::generate::apache2htaccess>.


=head1 CONDITIONS

This plugin provides some convenient conditions that you can add to
your routes. They will be always available and you can use them 
in your plugins. How to write I<conditions> is explained in 
L<Mojolicious::Guides::Routing/Conditions> and L<Mojolicious::Guides::Routing/Condition_plugins>.
TODO.

=cut

#=head2 require_formats
#
#Adds a more user friendly status message "415 - Unsupported Media Type"
#when you want to tell the user how to access a resourse.
#See L<Ado::Control/require_formats> for details.


=head1 SEE ALSO

L<Ado::Command::generate::apache2htaccess>, L<Ado::Command::generate::apache2vhost>,
L<Mojolicious::Guides::Routing>, L<Mojolicious::Routes>, L<Ado::Plugin>, L<Ado::Manual::Plugins>,L<Mojolicious::Plugins>, 
L<Mojolicious::Plugin>, 


=head1 SPONSORS

The original author

=head1 AUTHOR

Красимир Беров (Krasimir Berov)

=head1 COPYRIGHT AND LICENSE

Copyright 2013-2014 Красимир Беров (Krasimir Berov).

This program is free software, you can redistribute it and/or
modify it under the terms of the 
GNU Lesser General Public License v3 (LGPL-3.0).
You may copy, distribute and modify the software provided that 
modifications are open source. However, software that includes 
the license may release under a different license.

See http://opensource.org/licenses/lgpl-3.0.html for more information.

=cut


