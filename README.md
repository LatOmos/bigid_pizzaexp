Redis server is running on kubernetes cluster -- deployed using helm https://bitnami.com/stack/redis/helm.

Application code is cloned - git clone https://github.com/LatOmos/bigid_pizzaexp.git

Updated server.js file to read redis server details from environment variables(REDIS_HOST and REDIR_PASSWORD).

```
client = redis.createClient({
    host: process.env.REDIS_HOST,
    port: 6379,
    password: process.env.REDIS_PASSWORD
});

client.on('error', err => {
    console.log('Error ' + err);
});
```
Dockerfile to build new image
Created helm chart(```helm create <chart_name>```) to deploy our application. This chart deploys application and creates LoadBalancer service to access the application over the internet.
Docker registry secret must be created before pushing/pulling image to private registry.

    kubectl create secret docker-registry pullimage --docker-server=docker.io --docker-username=<DockerUserName> --docker-password=<DockerPasswd> --docker-email=<docker-email-id> 
    
Create secret for redis details
```
kubectl create secret generic my-secret --from-literal=REDIS_HOST=<Redis IP> --from-literal=REDIS_PASSWORD=<Redis Password>     
```

Login to Docker registry before running automation.sh scrip.     
```
automation.sh scrip to automate
    - Build and pushing docker image private registry. Pass the docker image tag as input.
        ex: /automation.sh <tag>
    - Deploy application using helm chart: helm upgrade --install  demo ./pizza-express -f ./pizza-express/values.yaml --debug
    - Accessing application endpoint to test 200 status code.
```

Output of automation.sh:


<img width="704" alt="image" src="https://user-images.githubusercontent.com/88339614/155887065-315ecf97-5903-4962-a25f-886a2e780628.png">

<img width="551" alt="image" src="https://user-images.githubusercontent.com/88339614/155887179-c71a07cd-3f98-4a81-9080-0af52c054881.png">

<img width="719" alt="image" src="https://user-images.githubusercontent.com/88339614/155887378-c511636a-e073-4675-904c-6260b25ff4b2.png">
