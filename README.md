# megabasterd-docker

### Originally created by [gauravsuman007](https://github.com/gauravsuman007/megabasterd-docker)

A containerized app for megbasterd from https://github.com/tonikelope/megabasterd

This is an alpine container with noVNC which enables the running app GUI (Megabasterd) to be accessed from a web browser. I used the base image from https://github.com/jlesage/docker-baseimage-gui and configured it to run Megabasterd.

## Modifications
- changed MegaBasterd download during runtime rather time build time, allow for smaller image and ability to run any version with an environment variable
- automatically load optimized settings (SmartProxy list, download folder to correct place) during first time setup

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
    volumes:
      - "./config:/config:rw"
      - "./output:/output:rw"
```
- `VERSION` is an environment variable that can be used to specify the version of MegaBasterd to download. If not specified, the latest version (currrently 8.21) will be downloaded.
- this will not work if there is already a MegaBasterd.jar downloaded in your bind mount, you will need to delete it first
- `output` is the folder for the downloaded files

Due to some bugs with MegaBasterd, you'll need to restart the container after the first run to get it working with VNC.
```bash
docker compose up -d
docker compose restart megabasterd
```

### Step 2: Accessing the app and configuring it
The web UI can be accessed at port `5800`.
On the first run, go to the top menu "Edit" -> "Settings", you can add MEGA.nz API key (this may not be needed in newer version of MegaBasterd).

- MEGA API key (Under Advanced)

<img width="758" alt="image" src="https://user-images.githubusercontent.com/16671262/191016225-c36cb218-9b70-4e5d-afb8-fafd707fa239.png">


## Folder Structure
### Config
```
/config
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