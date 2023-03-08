#!/bin/bash

# Shell colors for echo outputs
GRN='\033[1;32m'
NC='\033[0m' # No Color

echo ""

if [[ $(docker ps -aq) ]]; then
    echo -e "${GRN}------------------------------------------"
    echo -e "        Nuking all the things..."
    echo -e "------------------------------------------"
    echo -e "${NC}"
    docker ps -a | grep -v CONTAINER | awk '{print $1}' | xargs docker stop; docker ps -a | grep -v CONTAINER | awk '{print $1}' | xargs docker rm; docker volume ls | grep -v DRIVER | awk '{print $2}' | xargs docker volume rm; docker network prune -f
else
    echo -e "${GRN}No containers to nuke.${NC}"
    echo ""
fi

echo ""
echo -e "${GRN}k3d:${NC}"
k3d cluster delete dc3

echo ""





