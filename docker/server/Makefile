default:
	@echo "make [build|run|clean|logs|shell|stop|kill]"

build:
	docker build --tag=genivi/go-server:latest .

run:
	docker run -d --name=go-server -p 8153-8154:8153-8154 -p 80:8153 -p 443:8154 genivi/go-server:latest
	@echo "WARNING - THIS IS A TEST RUN, YOU REALLY WANT TO SET UP A PERSISTENT VOLUME!"

# Example, to map artifacts drive and specific IP
#docker run -ti -d -v /gousers:/gousers -v /volumes/lv4_1500G/go-server-artifacts:/var/lib/go-server/artifacts --name=go-server2 -p 8153-8154:8153-8154 -p 104.227.2.123:80:8153 -p 104.227.2.123:443:8154 genivi/go-server:latest /sbin/my_init /bin/bash

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

