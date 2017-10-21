path = require 'path'
nodemiral = require 'nodemiral'
cli = require 'cli'
fs = require 'fs'
async = require 'async'
_settings = require "./settings"
CWD = process.cwd()
abs = require "abs"

getAppLocation = (pm2mConf)->  path.join pm2mConf.server.deploymentDir, pm2mConf.appName
getBackupLocation = (pm2mConf)-> path.join getAppLocation(pm2mConf), _settings.backupDir

class BashCmd
  appendCmd = (cmd1, cmd2)->
    if cmd1
      return "#{cmd1} && #{cmd2}"
    else
      return "#{cmd2}"
  constructor: (pm2mConf, rawCmd) ->
    if pm2mConf and rawCmd
      @pm2mConf = pm2mConf
      @rawCmd = rawCmd
    else
      throw new Error "You must pass a pm2mConf and a Command string..."
  getString: ()->
    {loadProfile, nvm} = @pm2mConf.server
    result = ""
    if loadProfile
      result = appendCmd result, "[[ -r #{loadProfile} ]] && . #{loadProfile}"
    if nvm
      if nvm.bin
        result = appendCmd result, "[[ -r #{nvm.bin} ]] && . #{nvm.bin}"
        if nvm.use
          use = nvm.use.replace /\./g, ''
          result = appendCmd result, "nvm use #{nvm.use} && export PM2_HOME=/home/$USER/.pm2meteor#{use}"
    result = appendCmd result, @rawCmd
    return result

cmdString = (pm2mConf, cmd)->
  new BashCmd(pm2mConf, cmd).getString()

# Remote tasks
module.exports =
  getRemoteSession: (pm2mConf)->
    session = nodemiral.session "#{pm2mConf.server.host}",
      username: pm2mConf.server.username
      password: pm2mConf.server.password if pm2mConf.server.password
      pem: fs.readFileSync(abs(pm2mConf.server.pem)) if pm2mConf.server.pem
    ,
      ssh:
        port: pm2mConf.server.port if pm2mConf.server.port
    return session
  checkDeps: (session, pm2mConf, done)->
    cmd = cmdString pm2mConf, "(command -v node || echo 'missing node' 1>&2) && (command -v npm || echo 'missing npm' 1>&2) && (command -v pm2 || echo 'missing pm2' 1>&2)"
    session.execute cmd, {}, (err, code, logs)->
      if err
        done err
      else
        if logs.stderr and logs.stderr.length > 0 and /.*missing.*/.test(logs.stderr)
          console.log ""
          console.log logs.stderr
          done message: "Please make sure you have node, npm and pm2 installed on your remote machine!"
        else
          done()
  prepareHost: (session, pm2mConf, done)->
    cmd = cmdString pm2mConf, "mkdir -p #{path.join getAppLocation(pm2mConf), _settings.backupDir}"
    session.execute cmd, {}, (err,code,logs)->
      if err
        done err
      else
        if logs.stderr and logs.stderr.length > 0
          done message: "#{logs.stderr}"
        done()
  shipTarBall: (session, pm2mConf, done)->
    tarLocation = path.join CWD, _settings.bundleTarName
    destination = path.join getAppLocation(pm2mConf), _settings.bundleTarName
    console.log tarLocation
    console.log destination
    session.copy tarLocation, destination, {progressBar: true} , (err, code, logs)->
      if err
        done err
      else
        done()
  shipSettings: (session, pm2mConf, done)->
    fileLocation = path.join CWD, _settings.pm2EnvConfigName
    destination = path.join getAppLocation(pm2mConf), _settings.pm2EnvConfigName
    console.log fileLocation
    console.log destination
    session.copy fileLocation, destination, {progressBar: true} , (err, code, logs)->
      if err
        done err
      else
        done()
  extractTarBall: (session, pm2mConf, done)->
    cmd = cmdString pm2mConf, "cd #{getAppLocation(pm2mConf)} && rm -rf #{_settings.bundleName} && tar -xf #{_settings.bundleTarName}"
    session.execute cmd, {}, (err, code, logs)->
      if err
        done err
      else
        done()
  installBundleDeps: (session, pm2mConf, done)->
    serverLocation = path.join getAppLocation(pm2mConf), _settings.bundleName, "/programs/server"
    cmd = cmdString pm2mConf, "cd #{serverLocation} && node --version && npm i ."
    session.execute cmd, {}, (err, code, logs)->
      if err
        done err
      else
        done()
  startApp: (session, pm2mConf, done)->
    cmd = cmdString pm2mConf, "cd #{getAppLocation(pm2mConf)} && pm2 start #{_settings.pm2EnvConfigName}"
    session.execute cmd, {}, (err, code, logs)->
      if err
        done err
      else
        if logs.stderr
          done message: logs.stderr
        done()
  stopApp: (session, pm2mConf, done)->
    cmd = cmdString pm2mConf, "cd #{getAppLocation(pm2mConf)} && pm2 stop #{_settings.pm2EnvConfigName}"
    session.execute cmd, {}, (err, code, logs)->
      if err
        done err
      else
        if logs.stderr
          done message: logs.stderr
        done()

  status: (session, pm2mConf, done)->
    cmd = cmdString pm2mConf, "pm2 show #{pm2mConf.appName}"
    session.execute cmd, {}, (err, code, logs)->
      if err
        done err
      else
        if logs.stderr
          done(null, logs.stderr)
        if logs.stdout
          done(null, logs.stdout)

  backupLastTar: (session, pm2mConf, done)->
    cmd = cmdString pm2mConf, "cd #{getAppLocation(pm2mConf)} && mv #{_settings.bundleTarName} backup/ 2>/dev/null"
    session.execute cmd, {}, (err, code, logs)->
      if err
        done()
      else
        done()
  killApp: (session, pm2mConf, done)->
    cmd = cmdString pm2mConf, "pm2 delete #{pm2mConf.appName}"
    session.execute cmd, {}, (err, code, logs)->
      if err
        done err
      else
        done()
  reloadApp: (session, pm2mConf, reconfig, done)->
    if reconfig
      @hardReloadApp session, pm2mConf, done
    else
      @softReloadApp session, pm2mConf, done
  softReloadApp: (session, pm2mConf, done)->
    cmd = cmdString pm2mConf, "cd #{getAppLocation(pm2mConf)} && pm2 startOrReload #{_settings.pm2EnvConfigName}"
    session.execute cmd, {}, (err, code, logs)->
      if err
        done err
      else
        if logs.stderr
          console.log logs.stderr
        done()
  hardReloadApp: (session, pm2mConf, done)->
    cmd1 = cmdString pm2mConf, "cd #{getAppLocation(pm2mConf)} && pm2 delete #{pm2mConf.appName}"
    session.execute cmd1, {}, (err, code, logs)->
      if err
        done err
      else
        if logs.sterr
          console.log logs.stderr
        cmd2 = cmdString pm2mConf, "cd #{getAppLocation(pm2mConf)} && pm2 start #{_settings.pm2EnvConfigName}"
        session.execute cmd2, {}, (err, code, logs)->
          if err
            done err
          else
            if logs.stderr
              console.log logs.stderr
            done()
  deleteAppFolder: (session, pm2mConf, done)->
    cmd = cmdString pm2mConf, "rm -rf #{getAppLocation(pm2mConf)}"
    session.execute cmd, {}, (err, code, logs)->
      if err
        done err
      else
        if logs.stderr
          console.log logs.stder
        done()
  scaleApp: (session, pm2mConf, sParam, done)->
    cmd = cmdString pm2mConf, "pm2 scale #{pm2mConf.appName} #{sParam}"
    session.execute cmd, {}, (err, code, logs)->
      if err
        done err
      else
        if logs.stderr
          done message: logs.stderr
        if logs.stdout
          console.log logs.stdout
        done()
  getAppLogs: (session, pm2mConf, done)->
    cmd = cmdString pm2mConf, "pm2 logs #{pm2mConf.appName}"
    session.execute cmd, {onStdout: console.log}, (err, code, logs)->
      if err
        done err
      else
        if logs.stderr
          done message: logs.stderr
  revertToBackup: (session, pm2mConf, done)->
    appLocation = getAppLocation pm2mConf
    backupLocation = getBackupLocation pm2mConf
    cmd = cmdString pm2mConf, "mv #{path.join backupLocation, _settings.bundleTarName} #{path.join appLocation, _settings.bundleTarName}"
    console.log "executing #{cmd}"
    session.execute cmd, {}, (err, code, logs)->
      if err
        done err
      else
        if logs.stderr
          console.log "*** stderr while reverting to backup ***"
          done message: logs.stderr
        if logs.stdout
          console.log logs.stdout
        done()
