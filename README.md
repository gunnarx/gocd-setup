Helper scripts for Go CD installation (for GENIVI)
=================================================

go-agent
--------

Installing Go is already very simple in itself and documented in
[Go.CD documentation](https://www.go.cd/documentation/user/current/installation/index.html)

However to get a go-agent installed and configured for contacting go.genivi.org
the following is all that should be needed: (Please report any bugs)

```bash
$ curl https://raw.githubusercontent.com/gunnarx/gocd-setup/master/go_agent_install.sh | bash
```

go-server
---------

The installation script for the go-server has not been tested lately and might need a little fixing - let me know if you try it.

