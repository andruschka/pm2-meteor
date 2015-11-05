# cli = require 'cli'
program = require 'commander'
cmds = require './commandList'

program
  .version('0.3.0')

program
  .command('init')
  .description("init a pm2-meteor settings file")
  .action (instances)->
    cmds["init"]()
program
  .command('deploy')
  .description('deploy your App to the server(s)')
  .action (instances)->
    cmds["deploy"]()
program
  .command('start')
  .description('start your App on the server(s)')
  .action (instances)->
    cmds["start"]()
program
  .command('stop')
  .description('stop your App on the server(s)')
  .action (instances)->
    cmds["stop"]()
program
  .command('status')
  .description('print the status of your App (nodes)')
  .action (instances)->
    cmds["status"]()
program
  .command('generateBundle')
  .description('generates a tarball, containing the Nodejs build and a pm2-env.json file')
  .action (instances)->
    cmds["generateBundle"]()
program
  .command('undeploy')
  .description('undeploy your App from the server(s) - DANGEROUS!')
  .action (instances)->
    cmds["undeploy"]()
program
  .command('scale <instances>')
  .description('scale App to number-of-instances')
  .action( (instances)->
    cmds["scale"]("#{instances}")
  ).on '--help', ()->
    console.log "  Examples:"
    console.log "  $ pm2-meteor scale +2"
    console.log "  $ pm2-meteor scale -1"
    console.log "  $ pm2-meteor scale 4"
program.on '--help', ()->
  console.log "  Visit us:"
  console.log ""
  console.log "    http://betawerk.co/"
  console.log ""
program.parse(process.argv)
