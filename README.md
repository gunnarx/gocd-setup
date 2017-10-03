Helper scripts for Go CD installation (for GENIVI)
=================================================

Installing Go is already very simple in itself and documented in
[Go.CD documentation](https://www.go.cd/documentation/user/current/installation/index.html)

This project automates all steps to a go-agent installed and configured for
contacting go.genivi.org and it guarantees that the packages are installed
(and updated) for building GDP (and other Yocto based systems).

There are also scripts to reproduce the go.genivi.org server

Options and support levels -- Go Agent
--------------------------------------

Installing a standard go-agent for GDP/Yocto builds and other.
The agent becomes part of build cloud at go.genivi.org

1. Run in a Docker container (**Supported**)
2. Run natively (**Unsupported**, and please do not use:  We need absolute
   consistent behavior from the agents that are connected to go.genivi.org - therefore Docker is the best approach)
3. Install an agent connected to another Go-Server (**OK** You can edit configuration, but no guarnateed support).

Installing a VirtualBox enabled go agent

This is only needed to build a few VirtualBox image artifacts.  
1. Running vbox_agent in Docker. -- Currently **Unsupported**.  The settings
   for this are still in the docker/agent/Makefile but it's rarely tested.
   While it is technically possible to forward the virtualization device
   driver to a Docker container, it seems not worth the effort.
2. Install natively.  (**Supported** but not all steps are automated. You
   may need to install VirtualBox manually.  Ask if there are issues -
   there could be some host-dependent differences).


*Steps for installing with Docker (Go Agent)*

```bash
$ cd docker/agent
```

Now edit Makefile.  Consider, and (if desired) change the SETTINGS section
according to the comments there.  At minimum, set a unique host name. You
can use your own/your company name in the hostname for some advertisement
in exchange for providing your build agent.

**NOTE**  The builds use a *lot* of diskspace.  We recommend at least a
1TB or bigger disk at the configured PIPELINE_STORAGE location.  If you
configure 500G or so you should install a cronjob to free up space
once in a while, e.g. [pipeline-diskspace.sh](https://github.com/gunnarx/gocd-setup/blob/master/pipeline-diskspace.sh)
With a bigger disk, it doesn't hurt to do the same, or you should monitor
the disk space regularly.

If disks get full it really disrupts the CI flow because many builds will
fail unnecessarily, so try to avoid it.

```bash
$ make build  # <- ensure you have the rights to run docker, or use sudo
$ make run    # <- same here
```
Your agent should now start up, and contact the server. Notify a
go.genivi.org administrator to have them check the list of pending agents,
and enable yours.

Refer to docker/README.md for general documentation on docker variants.

Steps for (re-)installing Go Server (go.genivi.org)
---------------------------------------------------

1. Reinstalling (after fatal crash or whatever), in Docker, a replica of
   go.genivi.org (**Supported**. Quite well tested but not regularly) 

   Most settings should be scripted OK - perhaps with a few issues The
   pipeline definitions are stored in git and pushed to a backup directory:
   https://github.com/genivigo/server-config-backup and this should, if
   everything works, be automatically restored when this option is run.

   go.genivi.org should only run with HTTPS now. Make sure to refer to
   the [TLS certification installation pages](https://at.projects.genivi.org/wiki/x/Lobk)

   **WARNING**  The server uses a password file with hashed passwords.
   Details around setting it up not well documented yet, (since we have been
   waiting on LDAP support instead).  Please figure it out -- or ask.


2. Install your own replica of go.genivi.org natively or with Docker.
   (Possible, but limited support)


By default this creates a new instance of go.genivi.org. You can of course
run a similar instance for experiments, but we hope the primary
collaboration happens at go.genivi.org

There is limited support for this, but make sure you consider that the
server configuration push URL is changed to a repo in your control
(or disabled).

More Information
----------------

[Go CI server pages on GENIVI Wiki](https://at.projects.genivi.org/wiki/display/TOOL/Go+Continuous+Integration+Server)

Questions?  -- gandersson at@nospam@at genivi org

