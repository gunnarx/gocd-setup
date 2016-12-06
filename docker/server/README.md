# Go-server docker container HOWTO

* Study environment variables at the top of Makefile
* Change them in makefile, or in environment

Examples:
```
$ vi Makefile
$ export CONTAINER_NAME=my_other_name
```
Variables:

| ARTIFACT_STORAGE | /go-artifacts-temp/ | This is a large disk location (host path) where artifacts volume will be # mapped to. |
| CONTAINER_NAME | go-server | |
| IMAGE_NAME | genivi/go-server | genivi/go-server:latest will be built |
| GO_SERVER_IP | 127.0.0.1 | You should change this to the server's public IP address |

* Create docker image

```
$ make build
```

* Make sure the path defined by $ARTIFACT_STORAGE exists and is writable. Make sure the "go" user inside container can write to it on the host (make it writable by all and then when uid is known you can create limits)

* Run container

```
$ make run
```

* Attach to container (use the CONTAINER_NAME)0
```
$ docker attach go-server
```

* To exit from attached container:

Press *CTRL-P CTRL-Q*

(Do not Exit Bash shell - container will then stop!)

