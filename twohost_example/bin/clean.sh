#!/usr/bin/env bash


source setExampleEnv.sh

echo "GS_HOME is: $GS_HOME"

if [ ! -z "$(ls -A $GS_HOME/work)" ]; then
  rm -r $GS_HOME/work/*
fi

if [ ! -z "$(ls -A $GS_HOME/logs)" ]; then
  rm -r $GS_HOME/logs/*
fi

if [ -d "$GS_HOME/deploy/wan-gateway" ]; then
  rm -r $GS_HOME/deploy/wan-gateway
fi

if [ -d "$GS_HOME/deploy/wan-space" ]; then
  rm -r $GS_HOME/deploy/wan-space
fi
