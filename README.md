# pm2-meteor
A CLI tool, that will deploy your Meteor app (from your dev machine or from git) as Nodejs bundle and run it with PM2. (tested with Ubuntu and Freebsd hosts)

## A friendly info
This tool is still under construction and we will continue adding features.  
What is different about this tool:  
1. you can deploy from a git repo  
2. you can deploy to freebsd jails  
3. it uses PM2 to run your Meteor Apps  
4. you pass the path to the Meteor settings file, instead of copy-pasting them  
5. you can set the directory where your apps will be deployed  
6. you can scale up your App with one command  

### Why PM2?
PM2 is a process manager, that will run/restart Nodejs apps, just like forever - but:
- PM2 has build in load balancing and scaling features
- PM2 also runs bash / python / ruby / coffee / php / perl
- We tested PM2 with some of our complex Meteor apps and it performed well (while forever crashed them without any notable reasons)

### check out PM2 here: http://pm2.keymetrics.io/

## Installation
```
$ npm i -g pm2-meteor
```
You should have Nodejs, npm and PM2 installed on your host machine.  
pm2-meteor won't install global tools on your server! This is your job ;-)

## Usage
### 1. Init a pm2-meteor.json config file into an empty dir
```
$ mkdir ninjaApp_deployment
$ cd ninjaApp_deployment
$ pm2-meteor init
```

### 2. Complete the generated pm2-meteor.json file
```
{
  // the name of your app
  "appName": "ninjaApp",

  // where your app is located
  "appLocation": {
    "local": "~/Workspace/ninjaApp"
  // or you can also deploy with git ;-)
  // (use username:password@github.com/... for authentication)
  //   "git": "https://user:password@github.com/andruschka/ninjaApp",
  //   "branch": "production"
  },

  // where the meteor settings are located
  "meteorSettingsLocation":"~/Workspace/ninjaApp/settings/production.json",
  // or RELATIVE to app root, if you are deploying with git
  // "meteorSettingsLocation":"settings/production.json",

  // build flags for Meteor
  "meteorBuildFlags": "--architecture os.linux.x86_64"

  // runs as command in the meteor app before building
  "prebuildScript": "",
  // say you are still using meteorite and want to install deps before deploying:
  // "prebuildScript": "mrt install",

  // the env vars
  // (METEOR_SETTINGS will be generated from your meteor-settings file)
  "env": {
    "ROOT_URL": "http://ninja.my-host.com",
    "PORT": 4004,
    "MONGO_URL": "mongodb://localhost:27017/ninjaApp"
  },

  // infos for deployment
  "server": {
    "host": "my-host.com",
    "username": "nodejs",
    "password": "trustno1",
    // or auth with pem file
    // "pem":"~/.ssh/id_rsa",
    // optional set port
    // "port": "22",

    // this dir will contain your apps
    // (app will be deployed to /opt/pm2-meteor/ninjaApp)
    "deploymentDir": "/opt/pm2-meteor",

    // exec mode for pm2
    "exec_mode": "cluster_mode",
    "instances": 2
  }
}
```

### 3. Deploy your app
```
$ pm2-meteor deploy
```
If you already have deployed this app before, the old app tar-bundle will be moved to a ./backup directory.  
If something goes wrong - ssh to your host and:
```
$ cd /opt/pm2-meteor/ninjaApp && rm -rf bundle
$ cd backup && tar -xf bundle.tar.gz -C ../
$ cd ../ && pm2 delete ninjaApp
$ pm2 start pm2-env.json
```

### 4. Control your app
```
$ pm2-meteor start
$ pm2-meteor stop
$ pm2-meteor status
```

### 5. SCALE your app
Start 2 more instances:
```
$ pm2-meteor scale +2
```

Shut-down 1 instance:
```
$ pm2-meteor scale -1
```

Down/Upgrade to 4 instances
```
$ pm2-meteor scale 4
```

## If you want to deploy the bundle by yourself
```
$ pm2-meteor generateBundle
```
then transfer it to your machine, unzip it and run
```
$ pm2 start pm2-env.json
```
## Example configs
Deploy from a private github repo and start 2 load balanced instances:
```
{
  "appName": "todos",
  "appLocation": {
    "git": "https://andruschka:bestPass123@github.com/andruschka/todos.git",
    "branch": "master"
  },
  "meteorSettingsLocation": "settings/production.json",
  "prebuildScript": "mrt install",
  "meteorBuildFlags": "--architecture os.linux.x86_64",
  "env": {
    "PORT": 3000,
    "MONGO_URL": "mongodb://localhost:27017/todos",
    "ROOT_URL": "http://todos.my-host.co"
  },
  "server": {
    "host": "my-host.co",
    "username": "nodejs",
    "pem": "~/.ssh/id_rsa",
    "deploymentDir": "/home/nodejs/",
    "exec_mode": "cluster_mode",
    "instances": 2
  }
}

```

Deploy a local app and run app in fork-mode:
```
{
  "appName": "todos",
  "appLocation": {
    "local":"~/Workspace/todos"
  },
  "meteorSettingsLocation": "~/Workspace/todos/settings/production.json",
  "prebuildScript": "",
  "meteorBuildFlags": "--architecture os.linux.x86_64",
  "env": {
    "PORT": 3000,
    "MONGO_URL": "mongodb://localhost:27017/todos",
    "ROOT_URL": "http://todos.my-host.co"
  },
  "server": {
    "host": "my-host.co",
    "username": "nodejs",
    "pem": "~/.ssh/id_rsa",
    "deploymentDir": "/home/nodejs/",
    "exec_mode": "fork_mode",
    "instances": 1
  }
}

```
