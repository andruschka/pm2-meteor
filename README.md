# pm2-meteor
A CLI tool, that will deploy your (from local or from git) Meteor app as nodejs-bundle and run it with pm2.

## Heads up!
This tool is still under construction -> use with caution!  
We decided to build this, because meteor-up didn't fit our requirements.  
That said, meteor-up is an awesome tool!
(We are running apps on ubuntu and freebsd, and want to run them with pm2)

## Installation
```
$ npm i -g pm2-meteor
```

## Usage
### 1. Init a pm2-meteor.json config file
```
$ mkdir -p pm2-meteor/ninjaApp_deployment && cd pm2-meteor/ninjaApp_deployment
$ pm2-meteor init
```

### 2. Complete the generated pm2-meteor.json file
```
{
  // the name of your app
  "appName": "ninjaApp",

  // where your app is located - ABSOLUTE PATH!
  "appLocation": "/Users/andrej/Workspace/meteor/ninjaApp",
  // or you can also deploy with git ;-)
  // "appLocation": {
  //   "git": "http://github.com/andruschka/ninjaApp",
  //   "branch": "production"
  // }

  // where the meteor settings are located - RELATIVE TO THE APP DIRECTORY!
  "meteorSettingsLocation":"settings/production.json",

  // the env vars
  // (METEOR_SETTINGS will be generated from your settings file)
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
    // your app will be deployed to /opt/pm2-meteor/ninjaApp
    "deploymentDir": "/opt/pm2-meteor",
    // exec mode for pm2
    "exec_mode": "cluster_mode",
    "instances": 2
  }
}
```

### 3. Deploy your app
```
pm2-meteor deploy
```
If you already have deployed this app before, the old app will be moved to a ./backup directory.  
In case something goes wrong ssh to your host and:
```
cd /opt/pm2-meteor/ninjaApp
mv backup/* ../
pm2 delete ninjaApp
pm2 start pm2-env.json
```

### 4. Control your app
```
pm2-meteor start
pm2-meteor stop
pm2-meteor status
```

## If you want to deploy your app yourself and just need a pm2-env.json
```
pm2-meteor generateEnvFile
```
