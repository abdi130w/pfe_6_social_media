#!/bin/bash

unzip community_service/volumes.zip -d community_service/
sudo chown -R 991:991 community_service/volumes/pictrs/

unzip courses_service/volumes.zip -d courses_service/
sudo chown 1000:1000 courses_service/volumes/
sudo chmod +x courses_service/volumes/

docker-compose -f courses_service/docker-compose.yml up -d
echo "started the courses service on https://localhost:8000"

docker-compose -f community_service/docker-compose.yml up -d
echo "started the community service on https://localhost:10633"
