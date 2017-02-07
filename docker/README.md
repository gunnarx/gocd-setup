NOTE
====

NOTE: This is the Docker readme.  Make sure to read the README.md in the
root directory also!

Helper scripts for Go CD installation (for GENIVI)
=================================================

To build image

```
$ make build
```

To run image

```
export CONTAINER_HOSTNAME="my-go-agent-name"
make run
```

Some other environment variables might also exist -- see Dockerfile.

*NOTE* Unless you have optimized your docker storage backend to handle
large (and efficient) storage then you very likely want to edit the Makefile to
set up a separate host mount volume for the pipelines storage (for agents) and
for the artifacts storage (for servers), and to a lesser extent also pipelines
for the server.  The volume should be mounted at /var/lib/go-agent/pipelines
inside the container -- see Makefile for details.

For example, modify the Makefile like so:
```
run:
   docker run -v /local/path:/var/lib/go-agent/pipelines <the other arguments>
```

How does it work?
=================

The Dockerfile uses phusion/baseimage, a Docker-optimized Ubuntu variant.
If you feel more comfortable with any other standard base image, you can
change it but there are other things to change.  The way services are set
up in phusion/baseimage is different from, for example, systemd.  You are
on your own - hack away.

OK, once the baseimage is there, the dockerfile installs git.

Thereafter it can git-clone gocd-setup (this same repository you are
looking at) inside the container and just use the scripts in the repo that
you find in the parent dir of this docker/ dir to install and configure the
server or agent.  This makes things self-contained and a git clone 
is one step instead of ADD-ing many scriptfiles into the container first.
less but beware of the pitfalls:

Hacking caveats
===============

1. Pitfall #1
Note that when doing make build a fresh copy of this repository is cloned
inside the container.  In other words local changes to scripts will *not* be
executed unless you commit and push, *and* possibly modify the Dockerfile
to clone from the same location.

2. Pitfall #2
*Even if you did push* the changes, remember that docker caches intermediate
steps.  If docker reuses the git clone step from a previous invocation you
will tear your hair out trying to understand why the changes are still not
having any effect.
Use --no-cache, or explicitly remove intermediate images to avoid it.

If this makes you crazy, changing the Dockerfile to ADD in the required
scripts from the local copy is left as an exercize for the reader.r

