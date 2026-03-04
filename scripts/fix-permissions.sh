#!/bin/bash
set -e

APP_DIR=/home/ec2-user/app

mkdir -p "$APP_DIR"
chown -R ec2-user:ec2-user "$APP_DIR"
chmod -R u+rwX "$APP_DIR"