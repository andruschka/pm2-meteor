cli = require 'cli'
cmds = require './commandList'

# Parse options
commands = ['init', 'deploy', 'start', 'stop', 'status', 'generateBundle']
options = cli.parse null, commands

# Go!
cmds[cli.command](options)
