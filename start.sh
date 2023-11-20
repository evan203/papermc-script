#!/bin/sh
PROJECT=paper
VERSION=1.20.2
RAM=4G

build=$(curl -s -X 'GET' "https://api.papermc.io/v2/projects/$PROJECT/versions/$VERSION" -H 'accept: application/json' | jq -r '.builds[-1]')
name="$PROJECT"-"$VERSION"-"$build".jar
[ -f "$name" ] || curl -X 'GET' "https://api.papermc.io/v2/projects/$PROJECT/versions/$VERSION/builds/$build/downloads/$name" -H 'accept: application/java-archive' --output "$name"
echo 'eula=true' > eula.txt

java -Xms"$RAM" -Xmx"$RAM" -jar "$name" --nogui
