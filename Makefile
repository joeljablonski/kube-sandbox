### --- CORE --- ###

build:
  sudo docker build -t joeljjablonski/kube-sandbox:v1.1 .
  
run:
  sudo docker run --rm --privileged -it \
	-v ${PWD}:/code \
	-w /code \
	--network host \
	joeljjablonski/kube-sandbox:v1.1



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
