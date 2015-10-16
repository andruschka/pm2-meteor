# pm2-meteor
A command line tool, that will generate a config json for running your Meteor app under PM2.  
This is just a beta, more functions - like deployment support - coming soon.

## Installation
```
$ npm i -g pm2-meteor
```

## Usage
```
$ cd myMeteorProject
$ pm2-meteor
```
1. Provide the cli with the needed infos (MONGO URL etc)
2. pm2-meteor will generate a #{appname}_pm2.json file into your meteor app
3. Then it will generate a node bundle into meteorApp/.build (if you wish so) and install the deps
4. Now go into the .build folder and start your app
```
$ cd .build
$ pm2 start pm2.json
```
