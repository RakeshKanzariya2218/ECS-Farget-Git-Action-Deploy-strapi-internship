# Docker Swarm # 

- Docker Swarm is a native clustering and orchestration tool for Docker containers. 
- It enables you to manage a cluster of Docker hosts (also called nodes) as a single virtual host. 
-This allows you to deploy, manage, and scale applications composed of multiple containers across different machines seamlessly. 


### Key component of docker swarm:

- Node : 
  - A node is an instance of the Docker engine, which can be either a manager or a worker.

- Manager Node: 
  - Responsible for managing the swarm, making decisions about the cluster, and scheduling services. It also handles the API requests.

- Worker Node: 
  -  Executes the tasks assigned by the manager node. Worker nodes do not participate in the management of the swarm.

- Service: 
  - A service defines how to run a specific task or container in the swarm. When you deploy a service, Docker Swarm creates and manages the desired number of replicas across the nodes.

- Task: 
  - A task is a running container managed by Docker Swarm. Each task corresponds to a service instance, and it is assigned to a worker node.

- Swarm:
  - A swarm is a cluster of Docker nodes that run in swarm mode. This cluster can be created by initializing a single manager node, which can then be joined by other manager and worker nodes.


### Architecture of docker swarm:

 - The architecture of the docekr swarm is contains main two components:
   
   1. Control Plane: 
      - Managed by manager nodes, the control plane is responsible for:

        - Maintaining the state of the swarm.
        - Scheduling tasks on worker nodes.
        - Providing an API for users to interact with the swarm.
        - Handling cluster management tasks such as scaling and updating services.


   2. Data Plane:
      - Composed of worker nodes, the data plane is responsible for running the containers (tasks) defined by the services. 
      - Worker nodes pull the images from the Docker registry, execute the containers, and report their status back to the manager nodes.

   

## Process:

- Step-1. 
  - Set up worker node and manager node security group:
  - Manager node security group enable inbound port :
    - ssh port 22
    - Custom TCP 2377
    - Custom TCP 7946
    - Custom UDP 7946
    - Custom UDP 4789
    - Custom Protocol 50 all 

  - Worker Node security group enable inbound port : 

    - ssh 22
    - Custom TCP 7946
    - Custom UDP 7946
    - Custom UDP 478
    - Custom Protocol 50 all


- Step-2: 
  - Launch 3 ec2 instances one as manage node and another two as a worker node 

- Step-3: 
  - Connect all 3 instances and inastall and enable  and start docker.
```
sudo yum install docker -y
sudo systemctl enable docker
sudo systemctl start docker
sudo docker version
```

- Step-4:
  - Also install docker-compose on all instances.
```
sudo yum install curl
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

- Step-5: 
  - The command below should be run on your manager node.
  ```
  docker swarm init
  ```
  - This command will initialize the docker swarm and make that instance as a manager node.

  - It will give one command inside the manager node to join worker node to manager node 
  - Copy that command and run inside the  worker node so your worker node will join to manager node.


- Step-6:
  - After join worker node with the manager node check inside the manager node worker node joined or not with this command.
  ```
  docker node ls
  ```
  - This command will show the list of node which is join with the manager node in the docker swarm.


   - From now on we will be working from the Swarm manager, so you no longer need to stay connected to the three worker nodes.




- Step-7:
  - Pull the docker image for testing purpose:
  ```
  docker pull nginx
  ```

- Step-8:
  - Create a service nginx to run the task 
  ```
  docker service create --name nginx-service --replicas 4 nginx
  ```
  - It will create 4 task(contaainer) to run the nginx image as container 

- Step: 9 
  - Check the containers with this command 
  ```
  docker service ps nginx-service
  ```
  - It will shows the running tasks 

###  Now if you want to create seervice by the yaml file than create one yaml file like 


- Step-10 :  nginx-service.yaml
```
version: '3.9'  # make sure version >= 3.0 for Swarm

services:
  rakesh:
    image: nginx:latest
    ports:
      - "80:80"       # Host:Container port
    deploy:
      replicas: 4
      restart_policy:
        condition: any
      placement:
        constraints:
          - node.role == worker  # optional: only deploy on worker nodes
```

- Field	Meaning
  - services:	 List of containers (like pods in K8s)
  - image:	 Docker image to use
  - ports:	 Map container port → host port
  - deploy.replicas: 	Number of container instances (like replicas in K8s deployment)
  - deploy.restart_policy.condition: 	When to restart container
  - deploy.placement.constraints: 	Optional rules for node selection
  



- Step-11:
  - Apply this yaml file to create a service:
  ```
  docker stack deploy -c nginx-service.yaml nginx-stack
  ```
  - -c rakesh-service.yml : Compose file to use
  - rakesh-stack : Stack name (all services will belong to this stack)


- Step-12: 
  - Check running services
  ```
   docker stack ps nginx-stack
  ```

- Step-13:
- Check running tasks 
```
docker stack ps nginx-stack
```


- Step-14:
  - Access the service
  - If you mapped 80:80 in ports:
  - Open in browser: http://<node-public-ip>




------------------------------------------------------------------

### Basic commands to handle docker swarm:

- Initialize swarm mode on your main node
```
docker swarm init
```

- Show swarm nodes
```
docker node ls
```

- Get join token (to add worker)
```
docker swarm join-token worker
```

- Join a new node as worker
```
docker swarm join --token <token> <manager-ip>:2377
```

- Deploy a service
```
docker service create --name web --replicas 3 -p 80:80 nginx
```

- List services
```
docker service ls
```

- Inspect tasks (containers) for a service
```
docker service ps web
```

- Remoove the serrvice 
```
docker service rm <service-name>
```

-  How to Remove a Swarm Stack
```
docker stack rm <stack-name>
```
- This removes all services and tasks in the stack.


- How to List Before Removing
 - Check all stacks:
```
docker stack ls
```

- Check services in a stack:
```
docker stack services <stack-name>
```

- Check tasks in a stack:
```
docker stack ps <stack-name>
```



---

- Get public ip of the all worker node inside the manager node 
- First save the key which you given at the time of create the worker node 
- after that give permission to manager node to read that key 
```
chmod 400 /root/key-1.pem
```
- This ensures only the owner (root) can read the key file — required by SSH.
- Run the command to fetch the public ip of all the worker nodes
```
for node in $(docker node ls --format '{{.Hostname}}'); do
  echo -n "Node: $node  ->  "
  ssh -i /root/key-1.pem -o StrictHostKeyChecking=no ec2-user@$node "curl -s ifconfig.me"
done
```


------------------------------------------

---

## Docker Swarm CronJobs

Docker Swarm does not have native support for CronJobs (like Kubernetes does).  
However, we can achieve similar functionality using **two main approaches**:

###  `docker service update` with crontab on Manager Node
You can use the host’s cron to trigger Swarm service updates or container restarts periodically.

**Example:**
```
crontab -e
```

- `0 */6 * * * docker service update --force nginx-service`
- This forces the service to restart every 6 hours.


---

## Conclusion

- Docker Swarm provides a powerful and simple clustering mechanism to manage containerized applications.  
- Although it does not natively support CronJobs, with minor automation or helper containers like `swarm-cronjob`,  
- we can easily achieve scheduled job execution within the Swarm environment.

- This project demonstrates a complete setup — from Swarm initialization to service orchestration and cron-like scheduling.



---------------------------------------------
# images

- ![1](<Screenshot 2025-10-10 094450.png>)
- ![2](<Screenshot 2025-10-10 094515.png>)
- ![3](<Screenshot 2025-10-10 094625.png>)
- ![4](<Screenshot 2025-10-10 095044.png>)