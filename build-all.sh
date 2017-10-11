#!/usr/bin/env bash

function note() {
    local GREEN NC
    GREEN='\033[0;32m'
    NC='\033[0m' # No Color
    printf "\n${GREEN}$@  ${NC}\n" >&2
}

cd lightbulb-api;                                     note "Building lightbulb-api..."    mvn clean install; cd -
cd lightbulb-spa;                                     note "Building lightbulb-spa..."    mvn clean install; cd -

find . -name "*SNAPSHOT.jar" -exec du -h {} \;

docker-compose build
