#!/bin/bash
# This script is intended to be run in the directory with your server .jar 
# 	file or the directory you intend to install a minecraft server.

pwdRoot=`pwd`
echo "Minecraft Version: "
read mcversion
echo "Checking to see if you have the latest build of PaperMC for Minecraft version $mcversion..."

# creates temp directory with name of the PID
tmpDir="/tmp/$$"
# check if temp directory exists first
if [ ! -d "$tmpDir" ] 
then
	mkdir $tmpDir
fi

# get latest build number of PaperMC
cd $tmpDir
latestPre=`curl -s https://papermc.io/api/v1/paper/$mcversion/latest | tr -d -c 0-9.` # json of latest build number of mcversion to only have numbers 0 through 9 and .
latest="${latestPre//$mcversion/}" # removes mcversion from that getting latest build number of paper


## check if local server is up to date
newFile=$pwdRoot/paper-$latest.jar
if [ -f "$newFile" ]
then # if latest build number matches local build number:
	echo "Your server is up to date using PaperMC build $latest."
    cd $pwdRoot
else # if .jar just downloaded doesn't exist:
	echo "PaperMC build $latest is available. Downloading the latest server jar..."
    cd $pwdRoot
    curl -JLO https://papermc.io/api/v1/paper/$mcversion/latest/download
    if [ -f "download" ];then # mis typeed server version makes a "download" json file
        echo "ERROR: You mis-typed server version. Try again. "
        rm -rf download
        exit 1
    fi
fi

rm -rf $tmpDir

# run the minecraft server
echo "GB of ram to allocate for server: "
read mem
echo "Minecraft server is starting!"

OPTS="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true"

java -Xms"$mem"G -Xmx"$mem"G $OPTS -jar $newFile
