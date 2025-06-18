# Astroneer Docker Server Makefile
# Variables
IMAGE_NAME := astroneer
IMAGE_TAG := latest
CONTAINER_NAME := astroneer-server
COMPOSE_FILE := docker-compose.yml
DATA_DIR := /opt/servers/Astroneer/serverdata

# Default target
.DEFAULT_GOAL := help

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

.PHONY: help build run stop clean clean-all logs shell restart status push health info setup-data

help: ## Display this help message
	@echo -e "$(BLUE)Astroneer Docker Server - Available Commands:$(NC)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ { printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

build: ## Build the Docker image
	@echo -e "$(YELLOW)Building Docker image $(IMAGE_NAME):$(IMAGE_TAG)...$(NC)"
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .
	@echo -e "$(GREEN)Build complete!$(NC)"

run: build setup-data ## Build and run the container with docker-compose
	@echo -e "$(YELLOW)Starting Astroneer server...$(NC)"
	docker-compose -f $(COMPOSE_FILE) up -d
	@echo -e "$(GREEN)Server started! Check logs with 'make logs'$(NC)"

stop: ## Stop the running container
	@echo -e "$(YELLOW)Stopping Astroneer server...$(NC)"
	docker-compose -f $(COMPOSE_FILE) down
	@echo -e "$(GREEN)Server stopped!$(NC)"

restart: ## Restart the container
	@echo -e "$(YELLOW)Restarting Astroneer server...$(NC)"
	docker-compose -f $(COMPOSE_FILE) restart
	@echo -e "$(GREEN)Server restarted!$(NC)"

logs: ## Show container logs (follow mode)
	@echo -e "$(BLUE)Following logs (Ctrl+C to exit)...$(NC)"
	docker-compose -f $(COMPOSE_FILE) logs -f

status: ## Show container status
	@echo -e "$(BLUE)Container Status:$(NC)"
	docker-compose -f $(COMPOSE_FILE) ps
	@echo ""
	@echo -e "$(BLUE)Docker Images:$(NC)"
	docker images | grep -E "(REPOSITORY|$(IMAGE_NAME))" || true

shell: ## Open a shell in the running container
	@echo -e "$(YELLOW)Opening shell in container...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec $(CONTAINER_NAME) /bin/bash

setup-data: ## Create data directory with proper permissions
	@echo -e "$(YELLOW)Setting up data directory...$(NC)"
	sudo mkdir -p $(DATA_DIR)
	sudo chown -R 1000:1000 $(DATA_DIR)
	@echo -e "$(GREEN)Data directory setup complete!$(NC)"

clean: stop ## Stop container and remove image
	@echo -e "$(YELLOW)Cleaning up...$(NC)"
	docker-compose -f $(COMPOSE_FILE) down --volumes
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG) 2>/dev/null || true
	@echo -e "$(GREEN)Cleanup complete!$(NC)"

clean-all: clean ## Remove all related Docker resources
	@echo -e "$(YELLOW)Removing all Docker resources...$(NC)"
	docker system prune -f
	docker volume prune -f
	@echo -e "$(GREEN)All resources cleaned!$(NC)"

push: ## Push image to registry (set REGISTRY variable)
	@if [ -z "$(REGISTRY)" ]; then \
		echo -e "$(RED)Error: Please set REGISTRY variable$(NC)"; \
		exit 1; \
	fi
	@echo -e "$(YELLOW)Pushing to $(REGISTRY)...$(NC)"
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)
	docker push $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)
	@echo -e "$(GREEN)Push complete!$(NC)"

health: ## Check container health
	@echo -e "$(BLUE)Container Health Status:$(NC)"
	docker inspect --format='{{.State.Health.Status}}' $(CONTAINER_NAME) 2>/dev/null || echo "Container not running"

info: ## Show build and runtime information
	@echo -e "$(BLUE)Build Information:$(NC)"
	@echo "Image Name: $(IMAGE_NAME):$(IMAGE_TAG)"
	@echo "Container Name: $(CONTAINER_NAME)"
	@echo "Data Directory: $(DATA_DIR)"
	@echo "Compose File: $(COMPOSE_FILE)"
	@echo ""
	@echo -e "$(BLUE)Available Ports:$(NC)"
	@echo "Game Port: 8777 (TCP/UDP)"
	@echo ""
	@echo -e "$(BLUE)Quick Start:$(NC)"
	@echo "1. make run    # Build and start server"
	@echo "2. make logs   # Watch logs"
	@echo "3. make stop   # Stop server"
