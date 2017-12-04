Login page fix
--------------

This is a hack which replaces the login screen with our custom one.

Note this script is necessary because whenever the go-server is restarted it
will reset the login screen again. (Perhaps it would be possible to properly
edit the template pages for the web generation framework that is being used,
but in this case the generated HTML is replaced instead)
just hacked the resulting HTML)

This means it can also break in the future, if the it's not going to be
In that case, the original page nees to be copied again, and edited to
insert our custom changes.  Diff the current new vs. original to understand
the changes.

In other words, this script must be run after restarting the go server.  This
procedure could be built into the docker container so that it runs
automatically but I have not put the effort into that since it's a brittle
solution anyhow...

The current page has been tested with go-server version 17.1.0 (4511).

----

The GENIVI logo is a trademark.  The graphics may not be reused without
following the rules outlined on the GENIVI home page.  Start at
http://genivi.org/genivi-logos-download

