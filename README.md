# astroneer-docker-server

Docker container to run Astroneer dedicated server on Linux.

## Features

- **Updated Base System**: Ubuntu 24.04 LTS
- **Modern Wine**: Latest stable Wine from official repositories
- **Secure Downloads**: HTTPS URLs for all downloads
- **Modern Docker Compose**: Version 3.8 with best practices
- **Health Monitoring**: Supervisor-based process management
- **VNC Access**: X11VNC for remote desktop access

## System Requirements

- Docker Engine 20.10+
- Docker Compose 2.0+
- At least 4GB RAM
- 10GB available disk space

## Quick Start

### Using Make (Recommended)

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd astroneer-docker-server
   ```

2. View available commands:
   ```bash
   make help
   ```

3. Build and run the server:
   ```bash
   make run
   ```

4. Monitor logs:
   ```bash
   make logs
   ```

5. Stop the server:
   ```bash
   make stop
   ```

### Manual Docker Commands

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd astroneer-docker-server
   ```

2. Build the image:
   ```bash
   docker build -t astroneer:latest .
   ```

3. Run with Docker Compose:
   ```bash
   docker-compose up -d
   ```

## Available Make Commands

- `make build` - Build the Docker image
- `make run` - Build and start the server
- `make stop` - Stop the running server
- `make restart` - Restart the server
- `make logs` - Follow server logs
- `make status` - Show container status
- `make shell` - Open shell in container
- `make clean` - Stop and remove image
- `make clean-all` - Remove all related Docker resources
- `make push` - Push image to registry (set REGISTRY variable)
- `make health` - Check container health
- `make info` - Show build information
- `make setup-data` - Create data directory with proper permissions

## Configuration

The server exposes port 8777 (TCP/UDP) for game connections. Server data is persisted in `/opt/servers/Astroneer/serverdata` on the host.

## Based On

Originally based on [docker-conanexiles](https://github.com/alinmear/docker-conanexiles).

## Updates

- **2025-06**: Major modernization update
  - Updated to Ubuntu 24.04 LTS
  - Latest Wine stable from official repositories
  - Updated Wine Mono and Gecko versions
  - Improved security with HTTPS downloads
  - Modern Docker Compose syntax
  - Fixed Python package installation for Ubuntu 24.04 PEP 668 compliance
  - Prefer system packages over pip when available
  - Added comprehensive Makefile for automated builds and management