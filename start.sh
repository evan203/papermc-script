#!/usr/bin/env bash
# +————————————————————————————————————————+
# |   paperMC start script - by Evan203    |
# |             version 2.3                |
# |         Updated Nov 24, 2020           |
# +————————————————————————————————————————+
#

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

# check dependencies
if [ ! -x "$(command -v jq)" ] || [ ! -x "$(command -v curl)" ]; then 
    packagesNeeded='curl jq'
    echo "Dependencies curl and/or jq are not installed. Attempting to install them (requires sudo)"
    if [ -x "$(command -v apk)" ];       then sudo apk add --no-cache "$packagesNeeded"
    elif [ -x "$(command -v apt-get)" ]; then sudo apt-get install "$packagesNeeded"
    elif [ -x "$(command -v dnf)" ];     then sudo dnf install "$packagesNeeded"
    elif [ -x "$(command -v zypper)" ];  then sudo zypper install "$packagesNeeded"
    elif [ -x "$(command -v pacman)" ];  then sudo pacman -S "$packagesNeeded"
    elif [ -x "$(command -v yum)" ];  then sudo yum install epel-release -y; sudo yum install "$packagesNeeded" -y
    else echo "FAILED TO INSTALL PACKAGE: Package manager not found. You must manually install: $packagesNeeded"; fi
else echo "dependencies are installed."
fi

# make sure start_config.yml exists. if not, create one with default values.
pwdRoot="$(pwd)"
startConfig=$pwdRoot/start_config.yml
if [ -f "$startConfig" ]; then
    echo "$startConfig exists."
else 
    echo "$startConfig does not exist. Creating one."
    touch "$startConfig"
    {
        echo "## Config for start.sh"
        echo project: 'paper'  
        echo mcver: 'ask' 
        echo mcram: 'ask' 
    } >> "$startConfig"
fi


# translate start_config.yml's data into paramaters in this script
eval "$(parse_yaml start_config.yml)"


if [[ "$mcver" == "ask" ]]; then
	echo "Minecraft Version: "
	read -r mcversion
else
	mcversion=$mcver
fi

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
latest="$(curl -s https://papermc.io/api/v2/projects/"$project"/versions/"$mcversion"/ | jq '.builds' | tail -2 | head -1 | sed 's/^ *//g')" # gets latest build number from .json, removes " from output

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

# run the minecraft server
if [[ "$mcram" == "ask" ]]; then
	echo "GB of ram to allocate for server: "
	read -r mem
else
	mem=$mcram
fi

echo "Minecraft server is starting!"

OPTS="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true"

java -Xms"$mem"G -Xmx"$mem"G "$OPTS" -jar "$newFile"

# https://www.shellcheck.net/
