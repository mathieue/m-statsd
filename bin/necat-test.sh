#!/bin/bash
send() {
  echo "$1" | nc -q 1 -u 127.0.0.1 8125
}

while true; do
  cat <<EOF | nc -q 1 -u 127.0.0.1 8125
globs:${RANDOM}|c
gorets:${RANDOM}|c|@0.1
glork:${RANDOM}|ms
jauge:${RANDOM}|g
EOF
  sleep 1
done