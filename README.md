# PaperMC Script (Linux)  
### How to install  
1. If `which jq` returns a file, move on to the next step. If not, [download jq](https://stedolan.github.io/jq/download/
"jq is a lightweight and flexible command-line JSON processor"). It is available in the offical Debian/Ubuntu, Fedora,
openSUSE, and Arch package repositories.  
2. `cd` into your server directory that contains your server's jar file.    
3. `wget https://raw.githubusercontent.com/evan203/papermc-script/master/start.sh`  

### Usage  
Running `./start.sh` will download the latest version of papermc in the minecraft version you specify. If you already 
have the most updated server jar, nothing will change. You will have to specify how much ram to allocate to the server. 
Then, it will sart a server with optimized JVM flags.  

### Configuration file
If you would like to specify default values for the default minecraft version and how much memory to dedicate, you can modify the
`server_config.yml` file. Here is an example of what it would look like if you want it to default to minecraft version 1.16.1
and have 4GB of memory every time you run the start script:
```yaml
## Config for start.sh
mcver: '1.16.1'
mcram: '4'
```
