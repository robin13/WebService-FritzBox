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

- bandwidth

    A wrapper around the /inetstat\_monitor endpoint which responds with a normalised hash.  The monitor web page
    on the fritz.box refreshes every 5 seconds, and it seems there is a new value every 5 seconds... 5 seconds is
    probably a reasonable lowest request interval for this method.

    Example response:

        ---
        available:
          downstream: 11404000
          upstream: 2593000
        current:
          downstream:
            internet: 303752
            media: 0
            total: 303752
          upstream:
            default: 33832
            high: 22640
            low: 0
            realtime: 1600
            total: 58072
        max:
          downstream: 342241935
          upstream: 655811

    The section `current` represents the current (last 5 seconds) bandwith consumption.
    The value `current.downstream.total` is the sum of the `media` and `internet` fields
    The value `current.upstream.total` is the sum of the respective `default`, `high`, `low` and `realtime` fields
    The section `available` is the available bandwidth as reported by the DSL modem.
    The section `max` represents

# COPYRIGHT

Copyright 2015, Robin Clarke 

# AUTHOR

Robin Clarke <robin@robinclarke.net>
