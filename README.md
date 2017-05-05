# pm2-meteor
A CLI tool, that will deploy your Meteor app (from your dev machine or from git) as Nodejs bundle and run it with PM2. (tested with Ubuntu and Freebsd hosts)

### Checkout [this short tutorial](http://pm2-meteor.betawerk.co/) - so it is kind of a collection of some links for setting up everything with some extra steps. (This is how we setup our Meteor machines - so if this works for us - maybe it will for you ;-) )

## A friendly info
This tool is still under construction and we will continue adding features.  
What is different about this tool:  
1. you can deploy from a git repo  
2. you can deploy to freebsd jails  
3. it uses PM2 to run your Meteor Apps  
4. you pass the path to the Meteor settings file, instead of copy-pasting them  
5. you can set the directory where your apps will be deployed  
6. you can scale your App in realtime with one command  

### Why PM2?
PM2 is a process manager, that will run/restart Nodejs apps, just like forever - but:
- PM2 has build in load balancing and scaling features
- PM2 also runs bash / python / ruby / coffee / php / perl
- We tested PM2 with some of our complex Meteor apps and it performed well (while forever crashed them without any notable reasons)

### check out PM2 here: http://pm2.keymetrics.io/

## TODO
- fork_mode (we recommend to use the cluster_mode)
- further sticky-session implementation (except of Meteor.environmentVars this works out of the box with PM2 cluster_mode)

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
  "meteorSettingsInRepo": false,
  // or RELATIVE to app root, if settings are located in git repo (this is not a good idea...)
  // "meteorSettingsLocation":"settings/production.json",
  // "meteorSettingsInRepo": true,

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
    // optional - set port
    // "port": "22",

    // this dir will contain your apps
    // (app will be deployed to /opt/pm2-meteor/ninjaApp)
    "deploymentDir": "/opt/pm2-meteor",

    // optional - will source a profile before executing tasks on the server
    // "loadProfile": "",

    // optional - NVM Support
    // if you are using nvm - make sure to fill out bin ("~/.nvm/nvm.sh" in most cases)
    // ! using multiple node versions - coming soon !
    // "nvm": {
    //    "bin": "",
    //    "use": ""
    // },

    // exec mode for pm2
    "exec_mode": "cluster_mode",
    "instances": 2
  },
  // optional - set this one if you want to undeploy your app
  // "allowUndeploy": true

  // optional - set this if you want to specify timestamps to the pm2 log-files
  // "log_date_format": "YYYY-MM-DD HH:mm Z"
}
```

### 3. Deploy your app
```
$ pm2-meteor deploy
```
If you already have deployed this app before, the old app tar-bundle will be moved to a ./backup directory.  

##### If you want to only deploy settings / env changes
```
$ pm2-meteor reconfig
```
Will send new pm2-env file to server and hard-restart your app.

##### If something goes wrong: revert to previous version
```
$ pm2-meteor revert
```
Will unzip the old bundle.tar.gz and restart the app


### 4. Control your app
```
$ pm2-meteor start
$ pm2-meteor stop
$ pm2-meteor status
$ pm2-meteor logs
```

### 5. SCALE your app
Start 2 more instances:
```
$ pm2-meteor scale +2
```

Down/Upgrade to 4 instances
```
$ pm2-meteor scale 4
```

### 6. Undeploy your app (DANGEROUS)
To delete your app from the PM2 deamon and delete all app files add "allowUndeploy":true to your pm2-meteor setting, then:  
```
$ pm2-meteor undeploy
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
