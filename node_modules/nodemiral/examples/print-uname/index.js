var fs = require('fs');
var nodemiral = require('../../');
var path = require('path');

var sshPrivateKey = fs.readFileSync(process.env.HOME + '/.ssh/id_rsa', 'utf8');
var session = nodemiral.session('45.55.171.58', {username: 'root', pem: sshPrivateKey}, {keepAlive: false});
var taskList = nodemiral.taskList('Getting and Printing `uname -a`');

var closeCnt = 0;
taskList.copy('copy passwd', {
  src: path.resolve(__dirname, "template.conf"),
  dest: '/tmp/hello'
});

taskList.execute('get it', {
  command: 'cat /tmp/hello'
}, function(stdout, stderr) {
  this.hello = stdout;
});

taskList.print('printing hello', {
  message: "\t Hello is: {{hello}}"
});

taskList.run(session, function() {
  session.close();
});