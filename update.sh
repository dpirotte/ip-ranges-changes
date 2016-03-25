#!/bin/bash

while sleep 120; do
  wget -q https://ip-ranges.amazonaws.com/ip-ranges.json -O ip-ranges.json

  if [[ $(git status -s ip-ranges.json) ]]; then
    git add ip-ranges.json
    git commit -m 'updating ip-ranges.json'
    git push
  fi
done
