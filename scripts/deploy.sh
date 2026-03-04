#!/bin/bash
set -euo pipefail

APP_DIR=/home/ec2-user/app
DEPLOY_LOG=$APP_DIR/deploy.log
APP_LOG=$APP_DIR/app.log

echo "========== Deploy 시작: $(date) ==========" | tee -a "$DEPLOY_LOG"

# (임시) 환경변수
export DB_PASSWORD=98RccX3xtc9sRSL

cd "$APP_DIR"

# 1) jar 찾기: 배포 방식에 따라 위치가 달라서 두 군데 모두 탐색
JAR_PATH=""
if ls "$APP_DIR"/*.jar >/dev/null 2>&1; then
  JAR_PATH=$(ls -1 "$APP_DIR"/*.jar | head -n 1)
elif ls "$APP_DIR"/build/libs/*.jar >/dev/null 2>&1; then
  # plain.jar 제외(스프링부트면 보통 plain이 아닌 fat jar를 실행해야 함)
  JAR_PATH=$(ls -1 "$APP_DIR"/build/libs/*.jar | grep -v plain | head -n 1 || true)
fi

if [ -z "${JAR_PATH}" ] || [ ! -f "${JAR_PATH}" ]; then
  echo "[ERROR] JAR 못 찾음. APP_DIR 내용:" | tee -a "$DEPLOY_LOG"
  ls -al "$APP_DIR" | tee -a "$DEPLOY_LOG"
  ls -al "$APP_DIR/build/libs" 2>/dev/null | tee -a "$DEPLOY_LOG" || true
  exit 1
fi

echo "[INFO] 실행할 JAR: $JAR_PATH" | tee -a "$DEPLOY_LOG"

# 2) 기존 프로세스 종료 (jar 경로 기반)
CURRENT_PID=$(pgrep -f "java -jar.*$(basename "$JAR_PATH")" || true)

if [ -z "$CURRENT_PID" ]; then
  echo "[INFO] 기존 애플리케이션 없음" | tee -a "$DEPLOY_LOG"
else
  echo "[INFO] 기존 애플리케이션 종료 PID=$CURRENT_PID" | tee -a "$DEPLOY_LOG"
  kill -15 $CURRENT_PID || true
  sleep 5
fi

# 3) 새 애플리케이션 실행
echo "[INFO] 애플리케이션 실행" | tee -a "$DEPLOY_LOG"
nohup java -jar "$JAR_PATH" >> "$APP_LOG" 2>&1 &

# 4) 8080 뜨는지 + 헬스 엔드포인트 검증 (최대 30초)
echo "[INFO] 기동 확인(최대 30초)" | tee -a "$DEPLOY_LOG"
for i in {1..10}; do
  if ss -lntp | grep -q ":8080"; then
    if curl -fsS --max-time 2 http://localhost:8080/get >/dev/null; then
      echo "[OK] 8080 LISTEN + /get 응답 OK" | tee -a "$DEPLOY_LOG"
      echo "========== Deploy 성공: $(date) ==========" | tee -a "$DEPLOY_LOG"
      exit 0
    fi
  fi
  echo "[WAIT] 아직 준비 안됨... ($i/10)" | tee -a "$DEPLOY_LOG"
  sleep 3
done

echo "[ERROR] 기동/헬스체크 실패" | tee -a "$DEPLOY_LOG"
echo "[DEBUG] ss -lntp:" | tee -a "$DEPLOY_LOG"
ss -lntp | tee -a "$DEPLOY_LOG" || true
echo "[DEBUG] 최근 app.log:" | tee -a "$DEPLOY_LOG"
tail -n 200 "$APP_LOG" | tee -a "$DEPLOY_LOG" || true
exit 1
