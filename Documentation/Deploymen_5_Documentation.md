<h1 align=center>Deployment 5 Documentation</h1>

## Deployment goal:
Deploy a containerized architecture using Docker, ECS, and Terraform
Create the entire Jenkins Pipeline from scratch

## Software and Tools Used:
- GitHub 
- Jenkins
- Docker
- Docker Hub
- Terraform
- Amazon ECS

## Set Up: 
- I first started this deployment off by creating one EC2 instance that will host Jenkins and its pipeline. On this EC2 I installed the Docker Plugin that would add Docker functionality within Jenkins.

## Agent EC2:
- I then spun up two more EC2s to become Jenkins agents for Docker and Terraform processes. The reason why I'm using two agents is to lighten the load for each EC2. In my 4th deployment, I ran into problems deploying my terraform infrastructure since the EC2 was overworked. By splitting up the work between multiple agents the load for each EC2 was reduced. 
- Both EC2’s also had Java installed to allow the Jenkins agent to run on it.

## Jenkins Credentials: 
- Before I began making the Jenkins pipeline I needed to add a variety of credentials.
- I started by setting up the agent profiles to allow Jenkins to use each EC2. I then added my Docker Hub Credentials to allow me to push the image of my application. I lastly added my AWS credentials that Terraform would require to construct my infrastructure.  

## GitHub:
- Once my credentials were set up I forked the deployment repo.
- For this deployment, I needed to build out the entire Jenkins pipeline from scratch. I chose to include 7 different stages. First I started with the build and testing stage. This is to check to see if the application is working. The next two stages were the Image creation and DockerHub push stages. Lastly, I create the target environment using a terraform init, plan and apply stages.

## Jenkins Pipeline (1/3):
- First I needed to build the virtual environment and test to see if my application was properly functioning. 

## Jenkins Pipeline (2/3):
- With the application successfully working it was time for me to add to the Jenkins file and containerize the application. I created a dockerfile that would package up the application along with its dependencies and allow me to run it. With the dockerfile created I ran:
```
stage('Create_image') {
        agent{label 'docker_agent'}
        steps{
          sh '''#!/bin/bash
	  sudo usermod -a -G docker jenkins	  
          docker build -t deployment5:latest .
          '''
        }
      }
```
- This stage lets me bundle up the application into an image. Once the deployment 5 image was created it was time for me to push it into Docker Hub. I ran:
```
stage('Push') {
        agent{label 'docker_agent'}
        steps{
          sh '''#!/bin/bash
          echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
	  docker tag deployment5:latest nasiryork/deployment5:latest
          docker push nasiryork/deployment5:latest
          '''
        }
      }  
```
- This stage takes the docker credential that I set and logs into my Docker Hub account on the Docker Agent. Once logged in my image gets tagged with my Docker Hub repository name and then pushed to Docker Hub.


## Jenkins Pipeline (3/3):
- Now That I have my image sent to Docker Hub I am now able to move on to the final portion of the pipeline, the creation of the terraform environment. To create the environment I needed to configure the intTerraform folder within GitHub. Inside I configure a Cluster to run my image within AWS ECS. This was housed in a VPC also spun up by Terraform.


## Diagram:

## Challenges:
- Throughout this deployment I ran into many different challenges, Involving the agents, and some of the docker stages.
- Originally with the Docker and Terraform agents even though I configured them properly they weren’t able to run the Jenkins agent. This was because in the formation of the EC2 I forgot to add one of the dependencies Java which even the Jenkins agents need to follow the Jenkins pipeline.
- Another Agent problem that I ran into came with the configuration of the Docker agent. After setting up all of the configurations for my deployment I turned off the EC2s that my agent was configured to. When I returned I turned on the EC2 and tried to build out my pipeline. Jenkins could not properly connect to the Agents to carry out the Docker portion of my deployment. This was because AWS does not keep the same IP for an instance unless otherwise stated. To resolve the issue I needed to reconfigure the new IP that my EC2 was assigned. 
- I also ran into problems when it came to using docker within the Jenkins Pipeline. When I initially tried to push my image to Docker Hub I was not able to. Even though I added my credentials to Jenkins I needed to give permission to my EC2.
I ran:
```
sudo groupadd docker
sudo usermod -aG docker $USER
chmod 777 /var/run/docker.sock
```
- These commands added a new group to my EC2 and gave it access to push my image into Docker Hub.
