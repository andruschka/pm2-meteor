# pm2-meteor
A CLI tool, that will deploy your Meteor app (from your dev machine or from git) as nodejs-bundle and run it with pm2.  
(tested with Ubuntu and Freebsd hosts)
## A friendly info
This tool is still under construction and we will continue adding features.  
We decided to build this, because meteor-up didn't fit our requirements. Here is why:
1. we wanted to be able to deploy from a git repo
2. we wanted to be able to deploy to freebsd
3. we wanted to use PM2 instead of forever
4. we wanted to be able to pass a settings file path instead of a whole Meteor setting
5. we wanted to have control over the deployment destination / directory

### Why PM2?
PM2 is a process manager, that will restart your nodejs apps, just like forever - but:
- PM2 has build in load balancing features
- PM2 also runs bash / python / ruby / coffee / php / perl
- PM2 has some more cool features
- We tested PM2 with some of our complex Meteor apps and it performed well (while forever crashed them without any notable reasons)

### check out PM2 here: http://pm2.keymetrics.io/

## Installation
```
$ npm i -g pm2-meteor
```
You should have nodejs, npm and pm2 installed on your machine. pm2-meteor wont install global tools. This is your job ;-)

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
