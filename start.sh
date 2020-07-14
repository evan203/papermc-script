#!/bin/bash
# This script is intended to be run in the directory with your server .jar file
# 	or the directory you intend to install a minecraft server.

pwdRoot=`pwd`
echo "Minecraft Version to Download: "
read mcversion
echo "Downloading papermc for version $mcversion"

#creates temp directory with name of the PID
tmpDir="/tmp/$$"
# Check if temp directory exists first
if [ ! -d "$tmpDir" ] 
then
	mkdir $tmpDir
fi

# opens the temporary directory to download the latest server .jar for the user-specified version
cd $tmpDir
curl -JLO https://papermc.io/api/v1/paper/$mcversion/latest/download
paperver=`ls -1`

# check if .jar file just downloaded exists in server directory
newFile=$pwdRoot/$paperver
if [ -f "$newFile" ]
then # if existing .jar matches what was just downloaded:
	echo "Your server is up to date."
else # if .jar just downloaded doesn't exist:
	echo "$paperver is available. Updating your server jar."
	cp $paperver $newFile
fi
cd $pwdRoot

rm -rf $tmpDir

echo "server executing $newFile"

OPTS="-Xms6G -Xmx6G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true"

java $OPTS -jar $newFile

