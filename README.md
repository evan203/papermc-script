# PaperMC Start Script (Linux)  
### Installation 
1. Install `curl`, `jq`, and Java 17 (for PaperMC 1.18 and up). 
2. Make a new directory for your server or cd into an existing server.   
3. `wget https://raw.githubusercontent.com/evan203/papermc-script/master/start.sh && chmod +x start.sh` 
4. Open start.sh with text editor. Set the project, version, and ram variables. 

### Example Systemd Service
1. `sudo wget -O /etc/systemd/system/papermc.service https://raw.githubusercontent.com/evan203/papermc-script/master/papermc.service` 
2. Sudo open `/etc/systemd/system/papermc.service` with a text editor and change the directories to where your server is and the user to your intended user. 
3. `sudo systemctl enable papermc && sudo systemctl start papermc`
4. `tmux a` to attatch to the server
5. `ctrl b` - `d` to detatch (but not stop the server) from the tmux shell
