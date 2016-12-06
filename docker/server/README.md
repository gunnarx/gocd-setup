# Go-server docker container HOWTO

* Study environment variables at the top of Makefile
* Change them in Makefile (or set them in environment before running make)

Examples:
```
$ vi Makefile
$ export CONTAINER_NAME=my_other_name
```
Variables:

| Name | Default value | Notes |
|------|---------------|-------|
| ARTIFACT_STORAGE | /go-artifacts/ | This is a large disk location (host path) where artifacts volume will be mapped to. |
| CONTAINER_NAME | go-server | |
| IMAGE_NAME | genivi/go-server | genivi/go-server:latest will be built |
| GO_SERVER_IP | 127.0.0.1 | You should change this to the server's public IP address |

* Edit .github.readme (instructions inside)

```
$ vi .github.readme
$ mv .github.readme .github
```

* Create docker image

```
$ make build
```

* Check the results of the build image for errors

* Make sure to copy the SSH key that was provided.  Add it to the GitHub account (or any equivalent SSH enabled server) that shall hold the server config backup.
** NOTE: For security reasons, use a separate Git account and not one that holds many other important files.

* Make sure the path defined by $ARTIFACT_STORAGE exists and is writable. Make sure the "go" user inside container can write to it on the host (make it writable by all and then when uid is known you can create limits) (It would be cleaner to user a fixed/known user-id but that's not implemented atm.)

Example:

```
$ mkdir /go-artifacts
$ chmod 777 /go-artifacts  # Lock down later by setting the user ID that matches the container's internal "go" user ID as owner

* Run container

```
$ make run
```

* Debug....  Study printouts/logs by attaching to container (use the CONTAINER_NAME)
```
$ docker attach go-server
```

* To exit from attached container:

Press *CTRL-P CTRL-Q*

(NOTE: not Exit Bash shell when attached - container will then stop!)

