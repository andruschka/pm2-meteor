path = require 'path'
nodemiral = require 'nodemiral'
cli = require 'cli'
fs = require 'fs'
_settings = require "./settings"
CWD = process.cwd()
abs = require "abs"
getAppLocation = (pm2mConf)->  path.join pm2mConf.server.deploymentDir, pm2mConf.appName

# Remote tasks
module.exports =
  getRemoteSession: (pm2mConf)->
    session = nodemiral.session "#{pm2mConf.server.host}",
      username: pm2mConf.server.username
      password: pm2mConf.server.password if pm2mConf.server.password
      pem: fs.readFileSync(abs(pm2mConf.server.pem)) if pm2mConf.server.pem
    return session
  checkDeps: (session, done)->
    session.execute "node --version && npm --version && pm2 --version", {}, (err, code, logs)->
      if err
        done err
      else
        if logs.stderr and logs.stderr.length > 0
          done message: "Please make sure you have node, npm and pm2 installed on your remote machine!"
        else
          done()
  prepareHost: (session, pm2mConf, done)->
    session.execute "mkdir -p #{path.join getAppLocation(pm2mConf), _settings.backupDir}", {}, (err,code,logs)->
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
  extractTarBall: (session, pm2mConf, done)->
    session.execute "cd #{getAppLocation(pm2mConf)} && tar -xf #{_settings.bundleTarName}", {}, (err, code, logs)->
      if err
        done err
      else
        done()
  installBundleDeps: (session, pm2mConf, done)->
    serverLocation = path.join getAppLocation(pm2mConf), _settings.bundleName, "/programs/server"
    session.execute "cd #{serverLocation} && npm i", {}, (err, code, logs)->
      if err
        done err
      else
        done()
  startApp: (session, pm2mConf, done)->
    session.execute "cd #{getAppLocation(pm2mConf)} && pm2 start #{_settings.pm2EnvConfigName}", {}, (err, code, logs)->
      if err
        done err
      else
        if logs.stderr
          done message: logs.stderr
        done()
  stopApp: (session, pm2mConf, done)->
    session.execute "cd #{getAppLocation(pm2mConf)} && pm2 stop #{_settings.pm2EnvConfigName}", {}, (err, code, logs)->
      if err
        done err
      else
        if logs.stderr
          done message: logs.stderr
        done()

  status: (session, pm2mConf, done)->
    session.execute "pm2 show #{pm2mConf.appName}", {}, (err, code, logs)->
      if err
        done err
      else
        if logs.stderr
          done(null, logs.stderr)
        if logs.stdout
          done(null, logs.stdout)

  backupLastTar: (session, pm2mConf, done)->
    session.execute "cd #{getAppLocation(pm2mConf)} && mv #{_settings.bundleTarName} backup/ 2>/dev/null", {}, (err, code, logs)->
      if err
        done()
      else
        done()
  reloadApp: (session, pm2mConf, done)->
    session.execute "cd #{getAppLocation(pm2mConf)} && pm2 startOrRestart #{_settings.pm2EnvConfigName}", {}, (err, code, logs)->
      if err
        done err
      else
        if logs.stderr
          console.log logs.stderr
        done()
