# Makefile

# BASE_IMAGE = cit_nw_pmid_search_img
APP_IMAGE = cit_nw_img
DATE_TAG :=  $(shell date +%Y-%m-%d)
CONTAINER_NAME= cit_nw_cont


.PHONY: all base build run clean

# Default: build both base and app
all: build

# # Build base image
# base:
# 	docker build -f Dockerfile.base -t $(BASE_IMAGE) .

# Build app image (depends on base)
# build: base
build:
	docker build -t $(APP_IMAGE):$(DATE_TAG) .

# Run the container
run:
	docker run -d -p 3333:3333 --name $(CONTAINER_NAME) $(APP_IMAGE):$(DATE_TAG)

# Start an existing (stopped) container
start:
	docker start $(CONTAINER_NAME)

# Stop a running container
stop:
	docker stop $(CONTAINER_NAME)

# Container access
bashexec:
	docker exec -it $(CONTAINER_NAME) bash
	

# Remove images
clean:
	docker rmi -f $(APP_IMAGE) 
