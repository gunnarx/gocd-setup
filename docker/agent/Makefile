default:
	@echo "make [build|run|clean|logs|shell|stop|kill]"

build:
	docker build --tag=genivi/go-agent:latest .

run:
	docker run -d --name=go-agent genivi/go-agent:latest
	@echo "WARNING - THIS IS A TEST RUN, YOU LIKELY WANT TO SET UP A SEPARATE STORAGE VOLUME!"

clean:
	@echo "docker rm go-agent"
	@docker rm go-agent >/dev/null || echo "Container removed already"
	@echo docker rmi genivi/go-agent:latest 
	@docker rmi genivi/go-agent:latest 2>/dev/null || echo "Image removed already"

logs:
	docker logs -f go-agent

shell:
	docker exec -it go-agent /bin/bash

stop:
	docker stop go-agent

kill:
	docker kill go-agent
	docker rm go-agent

