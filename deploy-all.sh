#!/usr/bin/env bash

function note() {
    local GREEN NC
    GREEN='\033[0;32m'
    NC='\033[0m' # No Color
    printf "\n${GREEN}$@  ${NC}\n" >&2
}

note "Login to aws..."
eval "$(aws ecr get-login --no-include-email --region eu-west-1)";


note "Tag and push lightbulb-api..."
docker tag lightbulb-api "$(aws ecr describe-repositories --repository-names=lightbulb-api --output json | jq -r '.repositories[0].repositoryUri'):latest"
docker push "$(aws ecr describe-repositories --repository-names=lightbulb-api --output json | jq -r '.repositories[0].repositoryUri'):latest"

note "Tag and push lightbulb-spa..."
docker tag lightbulb-spa "$(aws ecr describe-repositories --repository-names=lightbulb-spa --output json | jq -r '.repositories[0].repositoryUri'):latest"
docker push "$(aws ecr describe-repositories --repository-names=lightbulb-spa --output json | jq -r '.repositories[0].repositoryUri'):latest"


note "Undeploy lightbulb-api..."
kubectl delete pod lightbulb-api.gunnebo.se
note "Undeploy lightbulb-spa..."
kubectl delete pod lightbulb-spa.gunnebo.se

sleep 5

note "Redeploy lightbulb-api..."
kubectl create -f lightbulb-api/lightbulb-api.yml
note "Redeploy lightbulb-spa..."
kubectl create -f lightbulb-spa/lightbulb-spa.yml