#!/bin/bash

echo "Installing dependencies"
npm install

echo "Perform unit tests"
npm test
rm -rf node_modules

echo "Buidling docker images and pushing it to private repositoty"
# docker login -u $1 -p $2
docker build -t latmos/pizza-express:$1 .
docker push latmos/pizza-express:$1

echo "Installing chart locally using helm"
helm upgrade --install  demo ./pizza-express --set image.tag=$1 -f ./pizza-express/values.yaml --debug 
sleep 5 &
while [[ $(kubectl get pods -l app=pizza-express-demo -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 5; done
# kubectl port-forward svc/demo-pizza-express 8080:80 &
external_ip=""; while [ -z $external_ip ]; do echo "Waiting for end point..."; external_ip=$(kubectl get svc demo-pizza-express --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready-" && echo $external_ip;
# sleep 5 &
# process_id=$!
# echo "process id: $process_id"
# wait $process_id
echo "Accessing application endpoint and cheking status code"
#curl -I localhost:8080
curl -I $external_ip