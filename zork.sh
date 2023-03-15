#!/bin/bash

export CONSUL_HTTP_TOKEN=root

DC1="http://127.0.0.1:8500"
DC2="http://127.0.0.1:8501"
DC3="http://127.0.0.1:8502"

RED='\033[1;31m'
BLUE='\033[1;34m'
DGRN='\033[0;32m'
GRN='\033[1;32m'
YELL='\033[0;33m'
NC='\033[0m' # No Color

COLUMNS=12

clear

# ==========================================
#           1.1 Donkey Discovery
# ==========================================

DonkeyDiscovery () {

    echo -e "${GRN}"
    echo -e "=========================================="
    echo -e "    DC1/donkey/donkey (local AP export) "
    echo -e "==========================================${NC}"
    echo ""
    echo -e "${YELL}DC1/Default Read-Only Token: 00000000-0000-0000-0000-000000003333${NC}"
    echo -e "${YELL}DC1/donkey/default/donkey is exported to the default AP${NC}"
    echo ""
    COLUMNS=1
    PS3=$'\n\033[1;31mChoose an option: \033[0m'
    options=("API Discovery (health + catalog endpoints)" "Go Back")
    select option in "${options[@]}"; do
        case $option in
            "API Discovery (health + catalog endpoints)")
                echo ""
                echo -e "${YELL} Resolving DC1/donkey/donkey using the 'service' API: ${NC}"
                echo -e "${GRN} curl -s "$DC1"/v1/health/service/donkey?partition=donkey | jq -r '.[].Service.ID'${NC}"
                curl -s --header "X-Consul-Token: 00000000-0000-0000-0000-000000003333" "$DC1"/v1/health/service/donkey?partition=donkey | jq -r '.[].Service.ID'
                echo ""
                echo -e "${YELL} Resolving DC1/donkey/donkey using the 'catalog' API: ${NC}"
                echo -e "${GRN} curl -s "$DC1"/v1/catalog/service/donkey?partition=donkey | jq -r '.[].ServiceID' ${NC}"
                curl -s --header "X-Consul-Token: 00000000-0000-0000-0000-000000003333" "$DC1"/v1/catalog/service/donkey?partition=donkey | jq -r '.[].ServiceID'
                echo ""
                REPLY=
                ;;
            "Go Back")
                echo ""
                clear
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
}

# ==========================================
#           1 Service Discovery
# ==========================================

ServiceDiscovery () {

    echo -e "${GRN}"
    echo -e "=========================================="
    echo -e "            Service Discovery "
    echo -e "==========================================${NC}"
    echo ""
    COLUMNS=1
    PS3=$'\n\033[1;31mChoose an option: \033[0m'
    options=("DC1/donkey/donkey (local AP export)" "Go Back")
    select option in "${options[@]}"; do
        case $option in
            "DC1/donkey/donkey (local AP export)")
                DonkeyDiscovery
                ;;
            "Go Back")
                echo ""
                clear
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
        REPLY=
    done
}

# ==========================================
#         2 Manipulate Services
# ==========================================

ManipulateServices () {

    echo -e "${GRN}"
    echo -e "=========================================="
    echo -e "            Manipulate Services"
    echo -e "=========================================="
    echo -e "${NC}"
    COLUMNS=1
    PS3=$'\n\033[1;31mChoose an option: \033[0m'
    options=("Register Virtual-Baphomet" "De-register Virtual-Baphomet Node" "Go Back")
    select option in "${options[@]}"; do
        case $option in
            "Register Virtual-Baphomet")
                echo ""
                echo -e "${GRN}Registering Virtual-Baphomet${NC}"

                curl --request PUT --data @./configs/services/dc1-proj1-baphomet0.json --header "X-Consul-Token: root" localhost:8500/v1/catalog/register
                curl --request PUT --data @./configs/services/dc1-proj1-baphomet1.json --header "X-Consul-Token: root" localhost:8500/v1/catalog/register
                curl --request PUT --data @./configs/services/dc1-proj1-baphomet2.json --header "X-Consul-Token: root" localhost:8500/v1/catalog/register

                echo ""
                echo ""
                REPLY=
                ;;
            "De-register Virtual-Baphomet Node")
                echo ""
                echo -e "${GRN}De-registering 'virtual' Node${NC}"

                curl --request PUT --data @./configs/services/dc1-proj1-baphomet-dereg.json --header "X-Consul-Token: root" localhost:8500/v1/catalog/deregister

                echo ""
                echo ""
                REPLY=
                ;;
            "3")
                echo ""
                echo "Option 3"

                echo ""
                REPLY=
                ;;
            "Go Back")
                echo ""
                clear
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
}

# ==========================================
#         3 Unicorn Demo
# ==========================================

UnicornDemo () {

    echo -e "${GRN}"
    echo -e "=========================================="
    echo -e "            Unicorn Demo"
    echo -e "=========================================="
    echo -e "${NC}"
    echo -e "${YELL}The Unicorn-Frontend (DC1) Web UI is accessed from http://127.0.0.1:10000/ui/ ${NC}"
    echo ""
    COLUMNS=12
    PS3=$'\n\033[1;31mChoose an option: \033[0m'
    options=("Nuke Unicorn-Backend (DC1) Container" "Restart Unicorn-Backend (DC1) Container (root token)" "Restart Unicorn-Backend (DC1) Container (standard token)" "Nuke Unicorn-Backend (DC2) Container" "Restart Unicorn-Backend (DC2) Container (root token)" "Restart Unicorn-Backend (DC2) Container (standard token)" "Go Back")
    select option in "${options[@]}"; do
        case $option in
            "Nuke Unicorn-Backend (DC1) Container")
                echo ""
                echo -e "${GRN}Killing unicorn-backend (DC1) container...${NC}"

                docker kill unicorn-backend-dc1
                docker kill unicorn-backend-dc1_envoy

                echo ""
                echo -e "${YELL}Traffic from Unicorn-Frontend Service-Resolver (left side) should now route to Unicorn-Backend (DC2)${NC}"
                echo ""
                COLUMNS=12
                REPLY=
                ;;
            "Restart Unicorn-Backend (DC1) Container (root token)")
                echo ""
                echo -e "${GRN}Restarting Unicorn-Backend (DC1) Container...${NC}"

                docker-compose --env-file docker_vars/acl-root.env up -d 2>&1 | grep --color=never Starting

                echo ""
                echo -e "${YELL}Traffic from Unicorn-Frontend Service-Resolver (left side) should now fail-back to Unicorn-Backend (DC1)${NC}"
                echo ""
                COLUMNS=12
                REPLY=
                ;;
            "Restart Unicorn-Backend (DC1) Container (standard token)")
                echo -e "${GRN}Restarting Unicorn-Backend (DC1) Container...${NC}"

                docker-compose --env-file docker_vars/acl-secure.env up -d 2>&1 | grep --color=never Starting

                echo ""
                echo -e "${YELL}Traffic from Unicorn-Frontend Service-Resolver (left side) should now fail-back to Unicorn-Backend (DC1)${NC}"
                echo ""
                COLUMNS=12
                REPLY=
                ;;
            "Nuke Unicorn-Backend (DC2) Container")
                echo ""
                echo -e "${GRN}Killing unicorn-backend (DC3) container...${NC}"

                docker kill unicorn-backend-dc2
                docker kill unicorn-backend-dc2_envoy

                echo ""
                echo -e "${YELL}Traffic from Unicorn-Frontend Service-Resolver (left side) should now route to Unicorn-Backend (DC3)${NC}"
                echo ""
                COLUMNS=12
                REPLY=
                ;;
            "Restart Unicorn-Backend (DC2) Container (root token)")
                echo ""
                echo -e "${GRN}Restarting Unicorn-Backend (DC2) Container...${NC}"

                docker-compose --env-file docker_vars/acl-root.env up -d 2>&1 | grep --color=never Starting

                echo ""
                echo -e "${YELL}Traffic from Unicorn-Frontend Service-Resolver (left side) should now fail-back to Unicorn-Backend (DC1 or DC2)${NC}"
                echo ""
                COLUMNS=12
                REPLY=
                ;;
            "Restart Unicorn-Backend (DC2) Container (standard token)")
                echo -e "${GRN}Restarting Unicorn-Backend (DC2) Container...${NC}"

                docker-compose --env-file docker_vars/acl-secure.env up -d 2>&1 | grep --color=never Starting

                echo ""
                echo -e "${YELL}Traffic from Unicorn-Frontend Service-Resolver (left side) should now fail-back to Unicorn-Backend (DC1 or DC2)${NC}"
                echo ""
                COLUMNS=12
                REPLY=
                ;;
            "3")
                echo ""
                echo "Option 3"

                echo ""
                REPLY=
                ;;
            "Go Back")
                echo ""
                clear
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
}

# ==========================================
#            4 Kubernetes
# ==========================================

Kubernetes () {

    echo -e "${GRN}"
    echo -e "=========================================="
    echo -e "            Kubernetes"
    echo -e "=========================================="
    echo -e "${NC}"
    # echo -e "${YELL}The Unicorn-Frontend (DC1) Web UI is accessed from http://127.0.0.1:10000/ui/ ${NC}"
    COLUMNS=1
    PS3=$'\n\033[1;31mChoose an option: \033[0m'
    options=("Get DC3 LoadBalancer Address" "Kube Apply DC3/unicorn-frontend" "Kube Delete DC3/unicorn-frontend" "Kube Apply DC3/unicorn-backend" "Kube Delete DC3/unicorn-backend" "Go Back")
    select option in "${options[@]}"; do
        case $option in
            "Get DC3 LoadBalancer Address")
                echo ""
                echo -e "${YELL}kubectl get service consul-mesh-gateway -nconsul -ojson | jq -r .status.loadBalancer.ingress[0].ip ${NC}"
                kubectl get service consul-mesh-gateway -nconsul -ojson | jq -r .status.loadBalancer.ingress[0].ip
                echo ""
                COLUMNS=1
                REPLY=
                ;;
            "Kube Apply DC3/unicorn-frontend")
                echo ""
                echo -e "${YELL}kubectl apply -f ./kube/configs/dc3/services/unicorn-frontend.yaml ${NC}"
                kubectl apply -f ./kube/configs/dc3/services/unicorn-frontend.yaml
                echo ""
                COLUMNS=1
                REPLY=
                ;;
            "Kube Delete DC3/unicorn-frontend")
                echo ""
                echo -e "${YELL}kubectl delete -f ./kube/configs/dc3/services/unicorn-frontend.yaml ${NC}"
                kubectl delete -f ./kube/configs/dc3/services/unicorn-frontend.yaml
                echo ""
                COLUMNS=1
                REPLY=
                ;;
            "Kube Apply DC3/unicorn-backend")
                echo ""
                echo -e "${YELL}kubectl apply -f ./kube/configs/dc3/services/unicorn-backend.yaml ${NC}"
                kubectl apply -f ./kube/configs/dc3/services/unicorn-backend.yaml
                echo ""
                COLUMNS=1
                REPLY=
                ;;
            "Kube Delete DC3/unicorn-backend")
                echo ""
                echo -e "${YELL}kubectl delete -f ./kube/configs/dc3/services/unicorn-backend.yaml ${NC}"
                kubectl delete -f ./kube/configs/dc3/services/unicorn-backend.yaml
                echo ""
                COLUMNS=1
                REPLY=
                ;;
            "Go Back")
                echo ""
                clear
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
}

# ==========================================
#            5 Docker Function
# ==========================================

DockerFunction () {

    echo -e "${GRN}"
    echo -e "=========================================="
    echo -e "            Docker Function"
    echo -e "=========================================="
    echo -e "${NC}"
    # echo -e "${YELL}The Unicorn-Frontend (DC1) Web UI is accessed from http://127.0.0.1:10000/ui/ ${NC}"
    COLUMNS=1
    PS3=$'\n\033[1;31mChoose an option: \033[0m'
    options=("Reload Docker Compose (Root Tokens)" "Reload Docker Compose (Secure Tokens)" "Reload Docker Compose (Custom Tokens)" "Go Back")
    select option in "${options[@]}"; do
        case $option in
            "Reload Docker Compose (Root Tokens)")
                echo ""
                echo -e "${YELL}docker-compose --env-file ./docker_vars/acl-root.env up -d ${NC}"
                echo ""
                docker-compose --env-file docker_vars/acl-root.env up -d
                break
                ;;
            "Reload Docker Compose (Secure Tokens)")
                echo ""
                echo -e "${YELL}docker-compose --env-file ./docker_vars/acl-secure.env up -d ${NC}"
                echo ""
                docker-compose --env-file docker_vars/acl-secure.env up -d
                break
                ;;
            "Reload Docker Compose (Custom Tokens)")
                echo ""
                echo -e "${YELL}docker-compose --env-file ./docker_vars/acl-custom.env up -d ${NC}"
                echo ""
                docker-compose --env-file docker_vars/acl-custom.env up -d
                break
                ;;
            "Go Back")
                echo ""
                clear
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
}

# ==========================================
#              Main Menu
# ==========================================


PS3=$'\n\033[1;31mChoose an option: \033[0m'
options=("Service Discovery" "Manipulate Services" "Unicorn Demo" "Kubernetes" "Docker Compose")
echo ""
COLUMNS=1
select option in "${options[@]}"; do
    case $option in
        "Service Discovery")
            ServiceDiscovery
            ;;
        "Manipulate Services")
            ManipulateServices
            ;;
        "Unicorn Demo")
            UnicornDemo
            ;;
        "Kubernetes")
            Kubernetes
            ;;
        "Docker Compose")
            DockerFunction
            ;;
        "Quit")
            echo "User requested exit"
            echo ""
            exit
            ;;
        *)  echo "invalid option $REPLY";;
    esac
    REPLY=
done

            # echo -e "${YELL}Press something to go back"
            # read -s -n 1 -p ""
            # echo -e "${NC}"

