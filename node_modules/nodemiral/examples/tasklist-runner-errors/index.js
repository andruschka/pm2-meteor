var fs = require('fs');
var nodemiral = require('../../');

var SSH_PRIVATE_KEY = fs.readFileSync(process.env.HOME + '/.ssh/id_rsa', 'utf8');
var session1 = nodemiral.session('162.243.77.68', {username: 'root', pem: SSH_PRIVATE_KEY});
var session2 = nodemiral.session('162.243.68.104', {username: 'root', pem: SSH_PRIVATE_KEY});

//taskLists

var printUname = require('./printUname');
var printPasswd = require('./printPasswd');

//taskListsRunner

var runner = nodemiral.taskListsRunner();
runner.add(printUname, [session1, session2]);
runner.add(printPasswd, session1);
runner.run();