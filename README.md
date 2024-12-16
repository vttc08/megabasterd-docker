# megabasterd-docker-warpstack

## Updates (WARPStack)
WARPStack uses Cloudflare WARP Wireguard VPN with GlueTun to route the MegaBasterd's container traffic via Cloudflare's free VPN. It provide a system to automatically switch between WARP servers when download limit is reached, via built-in functions of MegaBasterd and external API for managing Docker containers. A high level overview and tutorial to setup WARP with Gluetun can be found on my documentation page: TBD. Setup WARPStack with the container [here](#step-11-optional---setting-up-warpstack).

Video Overview: TBD
### Why WARPStack?
MegaBasterd has SmartProxy feature and proxy list are often updated on Github. However, the proxies are slow and disconnect often, making it unusable to download larger files in 2024. Cloudflare WARP provide much faster speed.
### Limitations and Future Work
Currently, this setup requires an external API to manage the Docker container such as [OliveTin](https://olivetin.app/). It utilize the built-in functions of MegaBasterd which run a command when download limit is reached, the command will hard reset on both containers hoping for an IP change. However, GlueTun + WARP may not always provide a new IP address. Future work may include:
- [ ] less dependency on external API (eg. OliveTin or other Docker management tools), perhaps using Docker socket proxy?
- [ ] utilize SmartProxy feature rather than run command for seamless experience, as GlueTun may support proxy mode
- [ ] support for multiple instances of GlueTun for multiple proxies
- [ ] use YXIP script to optimize IP switching and change the configuration accordingly
- [ ] IPv6 rotation on supported networks

### Originally created by [gauravsuman007](https://github.com/gauravsuman007/megabasterd-docker)

A containerized app for megbasterd from https://github.com/tonikelope/megabasterd

This is an alpine container with noVNC which enables the running app GUI (Megabasterd) to be accessed from a web browser. I used the base image from https://github.com/jlesage/docker-baseimage-gui and configured it to run Megabasterd.

## Modifications
- changed MegaBasterd download during runtime rather time build time, allow for smaller image and ability to run any version with an environment variable
- automatically load optimized settings (SmartProxy list, download folder to correct place) during first time setup
- WARPStack settings to use with GlueTun and Cloudflare WARP Wireguard

## Setup
### Step 1: Setting up the docker container
I recommend using docker-compose, a typical script for that would look like:
``` yaml
version: '3'
services:
  megabasterd:
    image: vttc08/megabasterd
    container_name: megabasterd
    ports:
      - "5800:5800" # Web Browser
      - "5900:5900" # VNC client port
    environment:
      - jlesage_related_settings="UID,GID,TZ also goes here"
      - VERSION=8.21
      - WARPSTACK=true # Optional
    volumes:
      - "./config:/config:rw"
      - "./output:/output:rw"
```
- `VERSION` is an environment variable that can be used to specify the version of MegaBasterd to download. If not specified, the latest version (currrently 8.21) will be downloaded.
- this will not work if there is already a MegaBasterd.jar downloaded in your bind mount, you will need to delete it first
- `output` is the folder for the downloaded files
- `WARPSTACK` is an optional environment variable to enable WARPStack, see [here](#step-11-optional---setting-up-warpstack) for more information, you must set it to `true` to enable it, this is not enabled by default

Due to some bugs with MegaBasterd, you'll need to restart the container after the first run to get it working with VNC.
```bash
docker compose up -d
docker compose restart megabasterd
```
### Step 1.1: Optional - Setting up WARPStack
WARPStack uses the built-in feature of MegaBasterd to run a command when downloading limit is reached. MegaBasterd is also in GlueTun network which connects to Cloudflare WARP Wireguard VPN. The command needs to reset both containers which will hopefully change the IP address. 

By default, WARPStack is not enabled and SmartProxy is used. To enable WARPStack, you need to set the environment variable `WARPSTACK=true` in the docker-compose file. Setting this will disable SmartProxy as it will interfere with download limit command.

If SmartProxy is already enabled or vice versa. Changing the environment variable will not work. In this case, to switch between SmartProxy and WARPStack, you will need to do it manually.
- for SmartProxy, it's under `Settings` -> `Downloads` -> `SmartProxy`, if you want to use a list, add a `#` before the URL such as `#https://raw.githubusercontent.com/yourproxylist.txt`
- for WARPStack, first disable SmartProxy, then go to `Settings` -> `Advanced` -> `Execute this command` and enter the location of the reset script, the path is relative to the container eg. `/config/reset.sh`

The script to be created on the host should be located at the bind mount folder to `/config`. Since the script is executed in the container, it should only include path and binary accessible by the container. This is an example script that send POST request to OliveTin API to reset the containers:
```bash
#!/bin/sh
wget --post-data='{"actionId": "reset-megabasterd"}' --header='Content-Type: application/json' http://olivetin-server/api/StartAction
```
- since `curl` is not available in the container, `wget` is used instead
- you can use any other tools as long as it allows you to restart Docker containers while the script is executed in the container

### Step 2: Accessing the app and configuring it
The web UI can be accessed at port `5800`.
On the first run, go to the top menu "Edit" -> "Settings", you can add MEGA.nz API key (this may not be needed in newer version of MegaBasterd).

- MEGA API key (Under Advanced)

<img width="758" alt="image" src="https://user-images.githubusercontent.com/16671262/191016225-c36cb218-9b70-4e5d-afb8-fafd707fa239.png">


## Folder Structure
### Config
```
/config
├── reset.sh # optional script to use with WARPStack to reset the containers
├── MegaBasterd/
│   ├── MegaBasterd.run # script to run MegaBasterd
│   ├── loaded # flag to indicate if settings have been loaded
│   ├── jar/
│   │   ├── MegaBasterd.jar # main executable
│   │   ├── .megabasterd${VERSION}/
│   │   │   ├── megabasterd.db # settings file
```
### Update/Changing Version
The environment variable only download if the jar file is not found, so if you want to update the version, you will need to delete `MegaBasterd.jar` and `MegaBasterd.run` or optionally `loaded`.
```bash
rm -irf /bind/mount/config/MegaBasterd # this will delete the entire app folder and settings
```
- specifiy the new version in the `docker-compose.yml` as `VERSION=8.21` variable

Alternatively, you can supply your own jar file and place it in the `jar` folder.