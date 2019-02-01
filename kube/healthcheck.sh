#!/bin/sh
set -e

URL=${APP_HEALTCHECK_URL:-http://localhost:8080}
echo Trying $URL ...

status=$(wget -S "$URL" 2>&1 | grep "HTTP/" | awk '{print $2}')

if [[ $status = "200" ]]
then
    echo Successful healthcheck [http status code: $status]
else
    echo Healthcheck failed [http status code: $status]
    exit 1
fi
