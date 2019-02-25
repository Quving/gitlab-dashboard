build:
	docker build -t git.hoou.tech:4567/hoou/dasharama:master .
run:
	docker run -it --rm \
	    -v $(shell pwd):/workdir \
	    --link apollo-api \
	    --link dasharama-server \
	    -e APOLLO_API_HOST=http://apollo-api:6425 \
	    -e DASHARAMA_SERVER_API_HOST=http://dasharama-server:3000 \
	    -e GITLAB_HOST=${GITLAB_HOST} \
	    -e GITLAB_PRIVATE_ACCESS_TOKEN=${GITLAB_PRIVATE_ACCESS_TOKEN} \
	    -e DASHARAMA_AUTH_TOKEN=${DASHARAMA_AUTH_TOKEN} \
	    -p 3030:3030 \
	    git.hoou.tech:4567/hoou/dasharama:master

gitlab_v4_project_all:
	curl --header "Private-Token: ${GITLAB_PRIVATE_ACCESS_TOKEN}" https://git.hoou.tech/api/v4/projects

gitlab_v4_runner_all:
	curl --header "Private-Token: ${GITLAB_PRIVATE_ACCESS_TOKEN}" https://git.hoou.tech/api/v4/runners/all

gitlab_v4_runner_x:
	curl --header "Private-Token: ${GITLAB_PRIVATE_ACCESS_TOKEN}" 'https://git.hoou.tech/api/v4/projects/58/jobs?scope[]=pending&scope[]=success'

