cli = require 'cli'
async = require 'async'
localTasks = require './localTasks'
commonTasks = require './commonTasks'
remoteTasks = require './remoteTasks'
_settings = require './settings'

# CLI commands
module.exports =
  init: ()->
    localTasks.initPM2MeteorSettings (err)->
      if err
        cli.fatal "#{err.message}"
      else
        cli.info "#{_settings.pm2MeteorConfigName} created!", true
  deploy: (reconfig)->
    cli.spinner "Building your app and deploying to host machine"
    pm2mConf = commonTasks.readPM2MeteorConfig()
    session = remoteTasks.getRemoteSession pm2mConf
    async.series [
      (cb)->
        remoteTasks.checkDeps session, pm2mConf, cb
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
        remoteTasks.extractTarBall session, pm2mConf, cb
      (cb)->
        remoteTasks.installBundleDeps session, pm2mConf, cb
      (cb)->
        remoteTasks.reloadApp session, pm2mConf, reconfig, cb
    ], (err)->
      cli.spinner "", true
      if err
        localTasks.makeClean (err)-> cli.error err if err
        cli.fatal "#{err.message}"
      else
        localTasks.makeClean (err)-> cli.error err if err
        cli.ok "Deployed your app on the host machine!"
  reconfig: ()->
    cli.spinner "Deploying new env"
    pm2mConf = commonTasks.readPM2MeteorConfig()
    session = remoteTasks.getRemoteSession pm2mConf
    async.series [
      (cb)->
        localTasks.generatePM2EnvironmentSettings pm2mConf, cb
      (cb)->
        remoteTasks.shipSettings session, pm2mConf, cb
      (cb)->
        remoteTasks.reloadApp session, pm2mConf, true, cb
    ], (err)->
      cli.spinner "", true
      if err
        localTasks.makeClean (err)-> null
        cli.fatal "#{err.message}"
      else
        localTasks.makeClean (err)-> null
        cli.ok "Deployed new env settings"
  start: ()->
    cli.spinner "Starting app on host machine"
    pm2mConf = commonTasks.readPM2MeteorConfig()
    session = remoteTasks.getRemoteSession pm2mConf
    async.series [
      (cb)->
        remoteTasks.startApp session, pm2mConf, cb
    ], (err)->
      cli.spinner "", true
      if err
        cli.fatal "#{err.message}"
      else
        cli.ok "Started your app!"
  stop: ()->
    cli.spinner "Stopping app on host machine"
    pm2mConf = commonTasks.readPM2MeteorConfig()
    session = remoteTasks.getRemoteSession pm2mConf
    async.series [
      (cb)->
        remoteTasks.stopApp session, pm2mConf, cb
    ], (err)->
      cli.spinner "", true
      if err
        cli.fatal "#{err.message}"
      else
        cli.ok "Stopped your app!"
  status: ()->
    cli.spinner "Checking status"
    pm2mConf = commonTasks.readPM2MeteorConfig()
    session = remoteTasks.getRemoteSession pm2mConf
    async.series [
      (cb)->
        remoteTasks.status session, pm2mConf, cb
    ], (err, result)->
      cli.spinner "", true
      if err
        cli.fatal "#{err.message}"
      else
        cli.info result
  generateBundle: ()->
    cli.spinner "Generating bundle with pm2-env file"
    pm2mConf = commonTasks.readPM2MeteorConfig()
    async.series [
      (cb)->
        localTasks.generatePM2EnvironmentSettings pm2mConf, cb
      (cb)->
        localTasks.bundleApplication pm2mConf, cb
      (cb)->
        localTasks.makeCleanAndLeaveBundle cb
    ], (err)->
      cli.spinner "", true
      if err
        cli.fatal "#{err.message}"
      else
        cli.ok "Generated #{_settings.bundleTarName} with pm2-env file"
  undeploy: ()->
    cli.spinner "Undeploying your App"
    pm2mConf = commonTasks.readPM2MeteorConfig()
    unless pm2mConf.allowUndeploy and pm2mConf.allowUndeploy is true
      cli.fatal "Please set ´allowUndeploy´ to true in your pm2-meteor settings file!"
    session = remoteTasks.getRemoteSession pm2mConf
    async.series [
      (cb)->
        remoteTasks.killApp session, pm2mConf, cb
      (cb)->
        remoteTasks.deleteAppFolder session, pm2mConf, cb
    ], (err)->
      cli.spinner "", true
      if err
        cli.fatal "#{err.message}"
      else
        cli.ok "Undeployed your App!"
  scale: (opts)->
    cli.spinner "Scaling your App"
    pm2mConf = commonTasks.readPM2MeteorConfig()
    session = remoteTasks.getRemoteSession pm2mConf
    async.series [
      (cb)->
        remoteTasks.scaleApp session, pm2mConf, opts, cb
    ], (err)->
      cli.spinner "", true
      if err
        cli.fatal "#{err.message}"
      else
        cli.ok "Scaled your App"
  logs: ()->
    pm2mConf = commonTasks.readPM2MeteorConfig()
    session = remoteTasks.getRemoteSession pm2mConf
    async.series [
      (cb)->
        remoteTasks.getAppLogs session, pm2mConf, cb
    ], (err)->
      if err
        cli.fatal "#{err.message}"
  revert: ()->
    pm2mConf = commonTasks.readPM2MeteorConfig()
    session = remoteTasks.getRemoteSession pm2mConf
    async.series [
      (cb)->
        remoteTasks.revertToBackup session, pm2mConf, cb
      (cb)->
        remoteTasks.extractTarBall session, pm2mConf, cb
      (cb)->
        remoteTasks.installBundleDeps session, pm2mConf, cb
      (cb)->
        remoteTasks.reloadApp session, pm2mConf, true, cb
    ], (err)->
      cli.spinner "", true
      if err
        cli.fatal "#{err.message}"
      else
        cli.ok "Reverted and hard-restarted your app."
