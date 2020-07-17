# PaperMC Script (Linux)  
### How to install  
1. `cd` into your server directory that contains your server's jar file.  
2. `wget https://raw.githubusercontent.com/evan203/papermc-script/master/start.sh` 

### Usage  
Running `./start.sh` will download the latest version of papermc in the minecraft version you specify. If you already 
have the most updated server jar, nothing will change. You will have to specify how much ram to allocate to the server. 
Then, it will sart a server with optimized JVM flags.  

### Configuration file
If you would like to specify default values for the default minecraft version and how much memory to dedicate, you can modify the
`start_config.yml` file. Here is an example of what it would look like if you want it to default to minecraft version 1.16.1
and have 4GB of memory every time you run the start script:
```yaml
## Config for start.sh
project: 'paper' # paper, waterfall, or travertine
mcver: '1.16.1' # 'ask' or specified version
mcram: '4' # 'ask' or number amount in GB
```
