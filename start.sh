#!/bin/bash
# This script is intended to be run in the directory with your server .jar 
# 	file or the directory you intend to install a minecraft server.


# function for translating start_config.yml's data into paramaters in this script (credit to Stephan Farestam)
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}
pwdRoot=`pwd`

startConfig=$pwdRoot/start_config.yml
if [ -f "$startConfig" ]; then
    echo "$startConfig exists."
else 
    echo "$startConfig does not exist. Creating one."
    touch $startConfig
    echo "## Config for start.sh"  >> $startConfig ; echo "mcver: 'ask'"  >> $startConfig ; echo "mcram: 'ask'" >> $startConfig
fi

# translate start_config.yml's data into paramaters in this script
eval $(parse_yaml start_config.yml)

if [ $mcver == "ask" ]; then
	echo "Minecraft Version: "
	read mcversion
else
	mcversion=$mcver
fi


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
#latestPre=`curl -s https://papermc.io/api/v1/paper/$mcversion/latest | tr -d -c 0-9.` # json of latest build number of mcversion to only have numbers 0 through 9 and .
#latest="${latestPre//$mcversion/}" # removes mcversion from that getting latest build number of paper
latest=`curl -s https://papermc.io/api/v1/paper/$mcversion/latest | jq '.build' | sed -e 's/"//g'`

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
if [ $mcram == "ask" ]; then
	echo "GB of ram to allocate for server: "
	read mem
else
	mem=$mcram
fi



echo "Minecraft server is starting!"

OPTS="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true"

java -Xms"$mem"G -Xmx"$mem"G $OPTS -jar $newFile
