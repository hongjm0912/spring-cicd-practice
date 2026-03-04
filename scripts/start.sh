#!/bin/bash
set -e

APP_DIR=/home/ec2-user/app

JAR=$(ls -1 $APP_DIR/build/libs/*.jar | head -n 1)

echo "Starting Spring Boot..."

nohup java -jar "$JAR" > "$APP_DIR/nohup.out" 2>&1 &