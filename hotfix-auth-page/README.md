Login page fix
--------------

This is a ugly hack which replaces the login screen with our custom one.

Note this script is necessary because whenever the go-server is restarted it
will reset the login screen again (because we have not properly edited the
templates for the web generation framework being used, but just hacked the
resulting HTML)

In other words, run this script after restarting the go server.  This procedure
could be built into the docker container so that it runs automatically but I
have not put the effort into that.  It's a brittle solution anyhow...
Since it's very roughly replacing one page with another, it's not going to be
forward compatible!
The current page is designed for go-server version 19.1.0

----

The GENIVI logo is a trademark with restrictions.  The file may not be
copied and reused without following the rules outlined on the GENIVI home page.
Start at http://genivi.org/genivi-logos-download

