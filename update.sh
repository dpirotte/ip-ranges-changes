#!/bin/bash

while sleep 120; do
  wget -q --header "If-None-Match: \"$(test -e ip-ranges.json && md5sum ip-ranges.json | awk '{print $1}')\"" \
    https://ip-ranges.amazonaws.com/ip-ranges.json

  if [[ $? == 0 && $(git status -s ip-ranges.json && grep syncToken ip-ranges.json) ]]; then
    git add ip-ranges.json
    git commit -m 'updating ip-ranges.json'
    git push
  fi
done
