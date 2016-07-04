[![Stories in Ready](https://badge.waffle.io/strator-dev/docker-seafile-client.png?label=ready&title=Ready)](https://waffle.io/strator-dev/docker-seafile-client)
## Seafile Docker image

* github reference project : https://github.com/strator-dev/docker-seafile-client/
* docker hub referece image : https://hub.docker.com/r/stratordev/seafile-client/

### Concept

The goal of this image : to create a seafile client docker image.

### Easy usage
Choose a data path on your server path.
Choose the UID and GID you want to have in your seafile folders.

```bash
sudo mkdir -p /this/will/be/your/data/path
```

```bash
sudo docker \
  run \
  -d \
  -e "APP_UID=1001" \
  -e "APP_GID=1001" \
  -v "/this/will/be/your/data/path:/data" \
  --name="seafile-client" \
  stratordev/seafile-client
```

Your container is now syncing... nothing, but you're ready to add a new folder to sync.

Each time you want to add a new folder, just do:

```bash
sudo docker \
  run \
  -ti \
  --rm=true \
  -e "APP_UID=1001" \
  -e "APP_GID=1001" \
  -v "/this/will/be/your/data/path:/data" \
  --name="seafile-client-add" \
  stratordev/seafile-client \
  /sbin/my_init -- /addsync
```

You'll prompt few questions :

```
Forlder name ?
MyFolder
Folder ID ?
d1abee9b-3dc2-4062-86d5-0e010e9f9a22
Server url ?
https://seafile.example.com:8080
login mail ?
admin@example.com
Enter password for user admin@example.com :

```

Parameters are :
* **Forlder name** : The name of the folder on the client side
* **Folder ID** : The id with with hex values you'll find in the web site url when you're in your folder
* **Server url** : The start of the url containing protocol (http or https) and the hostname.
* **login mail** : The login you're using on the web site
* **password** : The password associated with the login

And now, just restart your `seafile-client` container

```
sudo docker rm -f seafile-client
sudo docker \
  run \
  -d \
  -e "APP_UID=1001" \
  -e "APP_GID=1001" \
  -v "/this/will/be/your/data/path:/data" \
  --name="seafile-client" \
  stratordev/seafile-client
```

You'll find your folder in `/this/will/be/your/data/path/files/MyFolder` 

### Configuration

* **APP_UID** : The UID for all the files in the data folder. You may change that from one launch to another. Default value is "0" (root)
* **APP_GID** : The GID for all the files in the data folder. You may change that from one launch to another. Default value is "0" (root)

### Advanced usage

you can put the files and configuration in two separate folders by mapping as volume `/data/config` and `/data/files`. Both should have `rw` access.

Ex:

```bash
sudo docker \
  run \
  -d \
  -e "APP_UID=1001" \
  -e "APP_GID=1001" \
  -v "/home/user/.config/seafile:/data/config" \
  -v "/home/user/my_seafile_dir:/data/files" \
  --name="seafile-client" \
  stratordev/seafile-client
```


