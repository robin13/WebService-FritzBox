# NAME

API::FritzBox

# DESCRIPTION

Interact with FritzBox devices

# ATTRIBUTES

- password

    Required.

- host

    Optional.  Default: fritz.box

- use\_https

    Optional.  Default: 0

- user\_agent

    Optional.  A new LWP::UserAgent will be created for you if you don't already have one you'd like to reuse.

- loglevel

    Optional.

# METHODS

- init

    Create the user agent log in (get a sid).

- get

    Get some path from the FritzBox.  e.g.

        my $response = $fb->get( path => '/internet/inetstat_monitor.lua?useajax=1&xhr=1&action=get_graphic' ); 

    Returns the HTTP::Response object

# COPYRIGHT

Copyright 2015, Robin Clarke 

# AUTHOR

Robin Clarke <robin@robinclarke.net>
