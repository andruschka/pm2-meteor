cli = require 'cli'
async = require 'async'
localTasks = require './localTasks'
commonTasks = require './commonTasks'
remoteTasks = require './remoteTasks'
_settings = require './settings'

# CLI commands
module.exports =
  init: (opts)->
    cli.spinner "Creating new pm2-meteor.json"
    localTasks.initPM2MeteorSettings opts, (err)->
      if err
        cli.spinner "", true
        cli.fatal "#{err.message}"
      else
        cli.spinner "#{_settings.pm2MeteorConfigName} created!", true
  deploy: ()->
    cli.spinner "Building and deploying your app on host machine"
    pm2mConf = commonTasks.readPM2MeteorConfig()
    session = remoteTasks.getRemoteSession pm2mConf
    async.series [
      (cb)->
        remoteTasks.checkDeps session, cb
      (cb)->
        remoteTasks.prepareHost session, pm2mConf, cb
      (cb)->
        localTasks.generatePM2EnvironmentSettings pm2mConf, cb
      (cb)->
        localTasks.bundleApplication pm2mConf, cb
      (cb)->
        remoteTasks.backupLastTar session, pm2mConf, cb
      (cb)->
        remoteTasks.shipTarBall session, pm2mConf, cb
      (cb)->
        localTasks.makeClean cb
      (cb)->
        remoteTasks.extractTarBall session, pm2mConf, cb
      (cb)->
        remoteTasks.installBundleDeps session, pm2mConf, cb
    ], (err)->
      if err
        localTasks.makeClean (err)-> cli.error err if err
        cli.spinner "", true
        cli.fatal "#{err.message}"
      else
        cli.spinner "Deployed your app on the host machine!", true
  start: ()->
    cli.spinner "Starting app on host machine"
    pm2mConf = commonTasks.readPM2MeteorConfig()
    session = remoteTasks.getRemoteSession pm2mConf
    remoteTasks.startApp session, pm2mConf, (err)->
      if err
        cli.spinner "", true
        cli.fatal "#{err.message}"
      else
        cli.spinner "Started your app!", true
  stop: ()->
    cli.spinner "Stopping app on host machine"
    pm2mConf = commonTasks.readPM2MeteorConfig()
    session = remoteTasks.getRemoteSession pm2mConf
    remoteTasks.stopApp session, pm2mConf, (err)->
      if err
        cli.spinner "", true
        cli.fatal "#{err.message}"
      else
        cli.spinner "Stopped your app!", true
  status: ()->
    cli.spinner "Checking status"
    pm2mConf = commonTasks.readPM2MeteorConfig()
    session = remoteTasks.getRemoteSession pm2mConf
    remoteTasks.status session, pm2mConf, (err, result)->
      if err
        cli.spinner "", true
        cli.fatal "#{err.message}"
      else
        cli.spinner "", true
        cli.ok result
  generateEnvFile: ()->
    cli.spinner "Generating pm2 env file"
    pm2mConf = commonTasks.readPM2MeteorConfig()
    localTasks.generatePM2EnvironmentSettings pm2mConf, (err)->
      if err
        cli.pinner "Oh oh.", true
        cli.fatal "#{err.message}"
      else
        cli.spinner "Generated #{_settings.pm2EnvConfigName}!"
