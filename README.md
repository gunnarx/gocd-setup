Helper scripts for Go CD installation (for GENIVI)
=================================================

Installing Go is already very simple in itself and documented in
[Go.CD documentation](https://www.go.cd/documentation/user/current/installation/index.html)

However to get a go-agent installed and configured for contacting go.genivi.org
the following is all that should be needed: (Please report any bugs)

```bash
$ curl https://raw.githubusercontent.com/gunnarx/gocd-setup/master/go_agent_install.sh | bash
```

There are also scripts for the GENIVI go-server, which are **significantly more complex**
But if all bugs have been ironed out by now then you should be able to do
this to reinstall the server\*
I'd recommend using Docker however (see furhter down).

```bash
$ curl https://raw.githubusercontent.com/gunnarx/gocd-setup/master/go_server_install.sh | bash
```

\* For the server, the docker setup is the one that is most tested/supported.

Therefore:
```bash
$ cd docker/server
```

And study the **README.md** in that directory!

It is recommended to also run the agent in a docker container.  There are
files in the docker/ subdirectory.  For the agent, this should suffice:

```bash
$ cd docker/agent
$ make build
$ make run
```

Refer to docker/README.md for general documentation on docker variants.

