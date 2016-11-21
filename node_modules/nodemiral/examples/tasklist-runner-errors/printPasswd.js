var nodemiral = require('../../');

var showPasswd = module.exports = nodemiral.taskList('Understanding Users');
showPasswd.execute('invoke cat', {
  command: 'cat /etc/passwd'
}, function(stdout, stderr) {
  this.passwd = stdout;
});

showPasswd.print('printing userinfo', {
  message: "{{passwd}}"
});