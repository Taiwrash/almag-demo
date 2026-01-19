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

# CONFIGURATION
DOCKER_HUB_ID="taiwrash"


# 1. Environment & Port Configuration
export FRONTEND_PORT=80
export BACKEND_PORT=8080

echo -e "${BLUE}🔍 Checking port availability...${NC}"
if lsof -Pi :80 -sTCP:LISTEN -t >/dev/null ; then
    echo -e "${YELLOW}⚠️  Port 80 is busy. Switching Almag to Port 3000 for this session...${NC}"
    export FRONTEND_PORT=3000
fi

# 2. Generate/Download the public compose file
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${BLUE}📥 Generating deployment configuration...${NC}"
    
    cat <<EOF > docker-compose.yml
services:
  backend:
    image: $DOCKER_HUB_ID/almag-backend:v1
    ports:
      - "\${BACKEND_PORT:-8080}:8080"
    volumes:
      - almag_data:/data
    environment:
      - DATABASE_PATH=/data/almag.db
      - JWT_SECRET=\${JWT_SECRET:-dev-default-secret-key}
      - GIN_MODE=release
    restart: always

  frontend:
    image: $DOCKER_HUB_ID/almag-frontend:v1
    ports:
      - "\${FRONTEND_PORT:-80}:80"
    environment:
      - VITE_API_URL=http://localhost:\${BACKEND_PORT:-8080}
    depends_on:
      - backend
    restart: always

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
