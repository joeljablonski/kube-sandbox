### --- CORE --- ###

VERSION=v1.6
IMAGE_NAME=kube-sandbox
DOCKER_USERNAME=joeljjablonski

build:
	sudo docker build -t ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION} .
  
run:
	sudo docker run --rm --privileged -it \
	-v ${PWD}:/code \
	-w /code \
	--network host \
	${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION} 

login:
	sudo docker login -u ${DOCKER_USERNAME}

push:
	sudo docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}

commit:
	git add .
	git commit -m '${m}'
	git push

### --- EXAMPLES --- ###

# inside docker container
load-app:
	docker build -t localhost:5000/app:latest -f ./app.dockerfile .
	docker push localhost:5000/app:latest
	kind load docker-image localhost:5000/app:latest
  
app-up:
	kubectl apply -f ./k8s/app

app-down:
	kubectl delete -f ./k8s/app
  
port:
	kubectl port-forward service/app 4001:4001
