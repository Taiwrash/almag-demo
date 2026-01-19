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

# 2. Generate deployment configuration
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

  tunnel:
    image: cloudflare/cloudflared:latest
    command: tunnel --url http://backend:8080
    restart: always

volumes:
  almag_data:
EOF


# 2. Check Docker
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Docker is not running.${NC}"
    exit 1
fi

# 3. Pull and Start
echo -e "${BLUE}🛳️  Pulling images...${NC}"
docker compose pull
docker compose up -d

# 4. Wait for Readiness
echo -e "\n${BLUE}⏳ Waiting for services to initialize...${NC}"
MAX_RETRIES=20
COUNT=0
READY=false

while [ $COUNT -lt $MAX_RETRIES ]; do
    if curl -s -o /dev/null http://localhost:$FRONTEND_PORT; then
        READY=true
        break
    fi
    echo -n "🚀 "
    sleep 2
    COUNT=$((COUNT + 1))
done

echo ""

if [ "$READY" = true ]; then
    echo -e "${GREEN}✅ Almag is now LIVE!${NC}"
    
    DEMO_URL="http://localhost:$FRONTEND_PORT"
    
    # Extract the Cloudflare Tunnel URL
    echo -e "${BLUE}🌐 Generating Public URL for GitHub Actions...${NC}"
    
    # Retry loop to find the URL in logs (it can take ~10-15 seconds)
    MAX_TUNNEL_RETRIES=10
    T_COUNT=0
    TUNNEL_URL=""
    
    while [ $T_COUNT -lt $MAX_TUNNEL_RETRIES ]; do
        echo -n "☁️  "
        TUNNEL_URL=$(docker compose logs tunnel 2>&1 | grep -o 'https://.*\.trycloudflare\.com' | head -n 1)
        if [ ! -z "$TUNNEL_URL" ]; then
            break
        fi
        sleep 3
        T_COUNT=$((T_COUNT + 1))
    done
    echo ""

    echo -e "\n${MAGENTA}------------------------------------------${NC}"
    echo -e "${MAGENTA}🎉 SUCCESS! Your Almag instance is ready.${NC}"
    echo -e "${MAGENTA}🔗 Web Dashboard: ${YELLOW}$DEMO_URL${NC}"
    
    if [ ! -z "$TUNNEL_URL" ]; then
        echo -e "${MAGENTA}📡 Public API URL: ${YELLOW}$TUNNEL_URL${NC}"
        echo -e "   (Use this URL in your GitHub Actions ALMAG_URL secret)${NC}"
    fi
    echo -e "${MAGENTA}------------------------------------------${NC}"
    
    # Try to open the browser automatically
    if which open > /dev/null; then
        open "$DEMO_URL"
    fi

    echo -e "\n${BLUE}📝 Next Steps:${NC}"
    echo -e "1. Create a new account on the landing page."
    echo -e "2. Copy the Public API URL to use in GitHub Actions."
    echo -e "3. To stop the demo, run: ${NC}docker compose down${NC}"
else
    echo -e "${RED}❌ Demo failed to start.${NC}"
    exit 1
fi
