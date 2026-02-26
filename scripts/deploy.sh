#!/bin/bash

APP_DIR=/home/ec2-user/app
JAR_NAME=$(ls $APP_DIR/build/libs/*.jar)
DEPLOY_LOG=$APP_DIR/deploy.log

echo "Deploy 시작" > $DEPLOY_LOG

# 기존 프로세스 종료
CURRENT_PID=$(pgrep -f $JAR_NAME)

if [ -z "$CURRENT_PID" ]; then
  echo "기존 애플리케이션 없음" >> $DEPLOY_LOG
else
  echo "기존 애플리케이션 종료" >> $DEPLOY_LOG
  kill -15 $CURRENT_PID
  sleep 5
fi

# 새 애플리케이션 실행
nohup java -jar $JAR_NAME > $APP_DIR/nohup.out 2>&1 &
