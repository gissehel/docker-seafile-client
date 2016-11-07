[![](https://images.microbadger.com/badges/image/stratordev/seafile-client.svg)](http://microbadger.com/images/stratordev/seafile-client "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/stratordev/seafile-client.svg)](http://microbadger.com/images/stratordev/seafile-client "Get your own version badge on microbadger.com")

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
  /addsync
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

| Variable | Usage |
|----------|-------|
| **APP_UID** | The UID for all the files in the data folder. You may change that from one launch to another. Default value is "0" (root) |
| **APP_GID** | The GID for all the files in the data folder. You may change that from one launch to another. Default value is "0" (root) |

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

### Using crane as docker manager

If you're using [**crane**](https://github.com/michaelsauter/crane) as a docker manager tool, here is a [crane.yaml](doc/crane.yaml) that match the first example (from the *Easy usage* section)

```yaml
containers:
    seafile-client-add:
        image: "stratordev/seafile-client"
        run:
            tty: true
            interactive: true
            rm: true
            volume:
                - "/opt/dockerstore/seafile-client:/data"
            env:
                - "APP_UID=1000"
                - "APP_GID=1000"
            cmd: "/addsync"
    seafile-client:
        image: "stratordev/seafile-client"
        run:
            detach: true
            volume:
                - "/opt/dockerstore/seafile-client:/data"
            env:
                - "APP_UID=1000"
                - "APP_GID=1000"
```

You then just have to type to start the server:

```bash
$ crane run seafile-client
```

And then, you can add a new folder by using the command:

```bash
$ crane run seafile-client-add
Forlder name ?
MyFolder
Folder ID ?
d1abee9b-3dc2-4062-86d5-0e010e9f9a22
Server url ?
https://seafile.example.com:8080
login mail ?
admin@example.com
Enter password for user admin@example.com :

$ crane run seafile-client
```

**Note** : Don't forget to re-run `crane run seafile-client` each time you've added a new folder.

### Related projects

* [docker-seafile](https://github.com/strator-dev/docker-seafile/) : A docker image for seafile server
* [docker-seafile-client](https://github.com/strator-dev/docker-seafile-client/) : A docker image for seafile client (interface less)
* [seafile](https://www.seafile.com/) : The seafile project main page
* [docker](http://docker.com/) : The docker project
