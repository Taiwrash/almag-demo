#!/bin/bash

# Almag One-Click Public Demo Script
# This version pulls images from Docker Hub and requires NO source code.

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# CONFIGURATION - Update these to your Docker Hub details
DOCKER_HUB_ID="taiwrash"
COMPOSE_URL="https://raw.githubusercontent.com/taiwrash/almag-demo/main/docker-compose.yml"

echo -e "${MAGENTA}==========================================${NC}"
echo -e "${MAGENTA}   🛡️  Almag Cloud-Ready Demo Launcher 🛡️   ${NC}"
echo -e "${MAGENTA}==========================================${NC}"

# 1. Download the public compose file if it doesn't exist
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${BLUE}📥 Downloading deployment configuration...${NC}"
    # Use curl to download your public docker-compose.yml
    # curl -sSL $COMPOSE_URL > docker-compose.yml
    
    # FOR NOW: I will create a local copy since we are testing
    cat <<EOF > docker-compose.yml
services:
  backend:
    image: $DOCKER_HUB_ID/almag-backend:v1
    ports:
      - "\${BACKEND_PORT:-8081}:8080"
    volumes:
      - almag_data:/data
    environment:
      - DATABASE_PATH=/data/almag.db
      - JWT_SECRET=\${JWT_SECRET:-dev-default-secret-key}
      - GIN_MODE=release
  frontend:
    image: $DOCKER_HUB_ID/almag-frontend:v1
    ports:
      - "\${FRONTEND_PORT:-3000}:80"
    environment:
      - VITE_API_URL=http://localhost:\${BACKEND_PORT:-8081}
    depends_on:
      - backend
volumes:
  almag_data:
EOF
fi

# 2. Check Docker
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Docker is not running.${NC}"
    exit 1
fi

# 3. Pull and Start
echo -e "${BLUE}🛳️  Pulling images from Docker Hub...${NC}"
docker compose pull
docker compose up -d

# 4. Success Message
echo -e "\n${GREEN}✅ Almag is running!${NC}"
echo -e "🔗 URL: ${YELLOW}http://localhost:3000${NC}"
echo -e "\nTo stop the demo later, run: ${NC}docker compose down${NC}"
