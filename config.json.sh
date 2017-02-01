#!/bin/bash

if [ -z "$MAX_INSTANCES" ]; then
  MAX_INSTANCES=1
fi

#Blank by default 
HOST_LINE=
if [ -n "$NODE_HOST" ]; then
  HOST_LINE="\"host\": \"$NODE_HOST\","
fi

if [ -z "$NODE_PORT" ]; then
  NODE_PORT=5555
fi

CHROME_VERSION=$( sudo dpkg -s google-chrome-stable | grep Version | cut -d " " -f 2 | cut -d "-" -f 1 )
FIREFOX_VERSION=$( firefox -version | cut -d " " -f 3 )

cat << EOF
{
  "capabilities": [
    {
      "browserName": "chrome",
      "version": "$CHROME_VERSION",
      "maxInstances": $MAX_INSTANCES,
      "seleniumProtocol": "WebDriver"
    },
    {
      "browserName": "firefox",
      "version": "$FIREFOX_VERSION",
      "maxInstances": $MAX_INSTANCES,
      "seleniumProtocol": "WebDriver"
    }
  ],
  "proxy": "org.openqa.grid.selenium.proxy.DefaultRemoteProxy",
  "maxSession": $MAX_INSTANCES,
  $HOST_LINE
  "port": $NODE_PORT,
  "register": true,
  "registerCycle": 5000
}
EOF
