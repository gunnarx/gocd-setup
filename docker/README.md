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

*NOTE* Unless you have optimized your docker storage backend to handle
large (and efficient) storage then you probably want to edit the Makefile
to set up a separate volume for the pipelines storage.
It should be mounted at /var/lib/go-agent/pipelines inside the container.

For example, modify makefile like so:
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
server or agent.  This makes things very self-contained but beware
of the pitfall:  If you change the install scripts locally here, then those
won't affect the container build since it uses a fresh clone of the repo.

