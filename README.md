# pfe_6_social_media
PFE Liecence group 6 Social Media

# Services :
## community service :
lemmy instance with custom settings it uses lemmy-ui web front-end client, both the server and the ui are the offcial docker images

## courses service :
Uses wordpress official docker image along LearnPress plugin with custom entries (courses) and custom settings

## Files structure :
+ **Volumes.zip**: compressed container volumes to be extracted and mounted
+ **docker-compose**: docker compose file for each set of services
+ **config**: directory contains config files for set of services including nginx and databases
+ **schema.sql**: database schema for each service
+ **setup.sh**: script for the first-time setup extracts volumes, sets permissions and starts the services
+ **report/**: contains report original markdown files with the linked images
+ **report.pdf**: full report in pdf format
+ **map.md**: markdown file contains the report content requirements for each chapter

**Note**: for stoping and reusing the same containers without clearing the volumes and have changes persist , run from the pfe_6_social_media
+ to stop the services
```
docker-compose -f community-service/docker-compose.yml -f courses-service/docker-compose.yml down
```
+ to start the services
```
docker-compose -f community-service/docker-compose.yml -f courses-service/docker-compose.yml up -d
```

# Installation
The process of installation  is based on using docker due to the usage of the official images , instalation steps at [Docker engine](https://docs.docker.com/engine/install/) and it assumes a linux environment with **unzip** cli tool installed

### Clone the repository
```
git clone https://github.com/abdi130w/pfe_6_social_media.git
```
### move to the directory
```
cd pfe_6_social_media/
```
### give execution permissions to setup.sh
```
chmod +x setup.sh
```
### start the setup
```
./setup.sh
```

After the services has started , you can vist the web applications at :

**localhost:8000** for the courses services

**localhost:10633** for the community service
