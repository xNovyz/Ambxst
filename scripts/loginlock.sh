#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo "Usage: $0 \"lock command\""
  exit 1
fi

COMMAND=$1

dbus-monitor --system "type='signal',interface='org.freedesktop.login1.Session',member='Lock'" |
  while read -r line; do
    if echo "$line" | grep -q "member=Lock"; then
      eval "$COMMAND"
    fi
  done
