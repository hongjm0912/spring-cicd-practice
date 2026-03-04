#!/bin/bash
set -e

echo "Validating service..."

for i in {1..30}
do
  if curl -s http://localhost:8080/get > /dev/null
  then
    echo "Service OK"
    exit 0
  fi
  sleep 1
done

echo "Service failed"
exit 1