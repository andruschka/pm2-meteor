fs = require 'fs'
cli = require 'cli'
_settings = require './settings'
CWD = process.cwd()
path = require 'path'

module.exports =
  readPM2MeteorConfig: ()->
    conf = null
    try
      conf = require(path.resolve(CWD, _settings.tryReadPm2MeteorConfigName))
      return conf
    catch err
      cli.fatal "Error while trying to read pm2-meteor config #{err.message}"
