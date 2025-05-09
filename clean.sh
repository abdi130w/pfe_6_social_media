#!/bin/bash

docker-compose -f community_service/ down -v
docker-compose -f courses_service/ down -v
