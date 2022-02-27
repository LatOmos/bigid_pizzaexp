#!/bin/bash

echo "---***---Installing dependencies---***---"
npm install

echo "---***---Performing unit tests---***---"
npm test
rm -rf node_modules


echo "---***---Buidling docker images---***---"
# docker login -u $1 -p $2
docker build -t latmos/pizza-express:$1 .

echo "---***---Pushing image to private repository---***---"
docker push latmos/pizza-express:$1

echo "---***---Installing chart using helm---***---"
helm upgrade --install  demo ./pizza-express --set image.tag=$1 -f ./pizza-express/values.yaml --debug

sleep 5 &
while [[ $(kubectl get pods -l app=pizza-express-demo -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 5; done

external_ip=""; while [ -z $external_ip ]; do echo "Waiting for end point..."; external_ip=$(kubectl get svc demo-pizza-express --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}"); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready-" && echo $external_ip;

echo "---***---Accessing application endpoint and cheking status code---***---"

curl -I $external_ip
