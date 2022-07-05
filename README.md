# PaperMC Script (Linux)  
### How to install  
1. `cd` into your server directory that contains your server's jar file.  
2. `wget https://raw.githubusercontent.com/evan203/papermc-script/master/start.sh` 
3. Modify the server configuration to your liking. Most sytems do not have the version of java installed requried for papermc, 
so you will likely need to download new binaries.

### Usage  
Running `./start.sh` will download the latest version of papermc in the minecraft version you specify. If you already 
have the most updated server jar, nothing will change. You will have to specify how much ram to allocate to the server. 
Then, it will sart a server with optimized JVM flags.  

### Configuration
If you would like to specify default values for the default minecraft version and how much memory to dedicate, you can 
modify the script file to change the variables `mcversion`, `project`, `mem` (use M or G), and `JAVA` 
(get latest java bins from https://adoptium.net/download and point that to the extracted binary)
