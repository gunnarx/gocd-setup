Helper scripts for Go CD installation (for GENIVI)
=================================================

Installing Go is already very simple in itself and documented in
[Go.CD documentation](https://www.go.cd/documentation/user/current/installation/index.html)

However to get a go-agent installed and configured for contacting go.genivi.org
the following is all that should be needed: (Please report any bugs)

```bash
$ curl https://raw.githubusercontent.com/gunnarx/gocd-setup/master/go_agent_install.sh | bash
```

There are also scripts for the go-server, which are significantly more complex.
If all bugs have been ironed out by now then you can do this to reinstall the server.
```bash
$ curl https://raw.githubusercontent.com/gunnarx/gocd-setup/master/go_server_install.sh | bash
```

Recommended to run agent and server in docker containers.  There are docker
files in the docker/ subdirectory.

Refer to docker/README.md for documentation on those.
