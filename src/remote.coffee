nodemiral = require 'nodemiral'
cli = require 'cli'
session = nodemiral.session 'test.xyz',
  username: ""
  password: ""


session.copy '/Users/andrejfritz/Workspace/tests/pm2/petrus/pm2-env.json', '/opt/pm2-meteor/petrus/pm2-env.json', {progressBar: true } , (err, code, logs)->
  if err
    console.log err
    cli.fatal "#{err.message}"
  else
    cli.info logs.stdout + logs.stderr
