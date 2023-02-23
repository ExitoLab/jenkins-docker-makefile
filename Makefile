# Makefile to install Jenkins Docker container and configure a job using Configuration as Code plugin

# Variables
CONTAINER_NAME = "jenkins"
JENKINS_HOME = $(shell pwd)/jenkins_home
CONFIG_SCRIPT = $(shell pwd)/jenkins.yaml
ADMIN_USER = admin
ADMIN_PASS = admin_password
JOB_NAME = my-job
JOB_SCRIPT = $(shell pwd)/job.groovy
IMAGE_NAME=jenkins/jenkins:lts

# Targets
all: run

re

# # Build Jenkins Docker image
# build:
	docker build -t $(IMAGE_NAME) .

# Run Jenkins Docker container
run: clean
	docker run -d --name $(CONTAINER_NAME) \
	  -p 8083:8080
	  -v $(JENKINS_HOME):/var/jenkins_home 
	  -e CASC_JENKINS_CONFIG=$(CONFIG_SCRIPT) 
	  -e JENKINS_ADMIN_ID=$(ADMIN_USER) 
	  -e JENKINS_ADMIN_PASSWORD=$(ADMIN_PASS) 
	  $(IMAGE_NAME)

# Stop and remove Jenkins Docker container
stop:
	docker stop $(CONTAINER_NAME)
	docker rm $(CONTAINER_NAME)


# Configure Jenkins job using Configuration as Code plugin and Job DSL plugin
config:
	docker exec -it $(CONTAINER_NAME) java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8083/ -auth $(ADMIN_USER):$(ADMIN_PASS) reload-configuration
	docker exec -it $(CONTAINER_NAME) java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8083/ -auth $(ADMIN_USER):$(ADMIN_PASS) groovy = < $(JOB_SCRIPT)

.PHONY: all build run stop config