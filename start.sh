#!/usr/bin/env bash
# +————————————————————————————————————————+
# |   paperMC start script - by Evan203    |
# |             version 2.4                |
# |         Updated Jul 5, 2022            |
# +————————————————————————————————————————+

# CONFIGURATION SETTINGS
mcversion="1.19"
project="paper"
mem="1400M"
JAVA="/usr/bin/java" # get latest java bins from https://adoptium.net/download and point this to the extracted binary

pwdRoot="$(pwd)"

echo "Checking to see if you have the latest build of $project for Minecraft version $mcversion..."

# creates temp directory with name of the PID
tmpDir="/tmp/$$"
# check if temp directory exists first
if [ ! -d "$tmpDir" ] 
then
	mkdir $tmpDir
fi

# get latest build number of PaperMC
cd "$tmpDir" || exit
latest="$(curl -s https://papermc.io/api/v2/projects/"$project"/versions/"$mcversion"/ | jq -r '.builds[-1]')" # gets latest build number from .json, removes " from output

## check if local server is up to date
newFile="$pwdRoot"/"$project"-"$mcversion"-"$latest".jar
if [ -f "$newFile" ]
then # if latest build number matches local build number:
	echo "Your server is up to date using $project build $latest."
    cd "$pwdRoot" || exit
else # if .jar just downloaded doesn't exist:
	echo "$project build $latest is available. Downloading the latest server jar..."
    cd "$pwdRoot" || exit
    curl -JLO https://papermc.io/api/v2/projects/"$project"/versions/"$mcversion"/builds/"$latest"/downloads/"$project"-"$mcversion"-"$latest".jar
    if [ -f "download" ];then # mis typeed server version makes a "download" json file
        echo "ERROR: You mis-typed server version. Try again. "
        rm -rf download
        exit 1
    fi
fi

rm -rf $tmpDir

echo "Minecraft server is starting!"

FLAGS="-XX:+UnlockExperimentalVMOptions -XX:+UseZGC -XX:+ZProactive -XX:ZCollectionInterval=600 -XX:+UseLargePages -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:+ParallelRefProcEnabled -XX:+PerfDisableSharedMem"

${JAVA} -server -Xmx"$mem" -Xms"$mem" ${FLAGS} -jar "$newFile" --nogui
