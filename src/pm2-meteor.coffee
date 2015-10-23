cli = require 'cli'
cmds = require './commandList'

# Parse options
commands = ['init', 'deploy', 'start', 'stop', 'status', 'generateEnvFile']
options = cli.parse null, commands

# Go!
cmds[cli.command](options)
