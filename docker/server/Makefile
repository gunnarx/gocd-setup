default:
	@echo "make [build|run|clean|logs|shell|stop|kill]"

build:
	docker build --tag=genivi/go-server:latest .

run:
	docker run -d --name=go-server -p 8153-8154:8153-8154 -p 80:8153 -p 443:8154 \
	           -v /go-pipelines:/var/lib/go-server/pipelines genivi/go-server:latest
	# Local changes, copy our user file into location
	tar cf - users | docker exec -i go-server tar xf - -C /var/go
	@echo "WARNING - THIS IS A TEST RUN, YOU REALLY WANT TO SET UP A PERSISTENT VOLUME!"
	@echo "FIXME -- need to setup gouser application also - share /gousers dir and no need to copy file"

clean:
	@echo "docker rm go-server"
	@docker rm go-server >/dev/null || echo "Container removed already"
	@echo docker rmi genivi/go-server:latest 
	@docker rmi genivi/go-server:latest 2>/dev/null || echo "Image removed already"

logs:
	docker logs -f go-server

shell:
	docker exec -it go-server /bin/bash

stop:
	docker stop go-server

kill:
	docker kill go-server
	docker rm go-server

