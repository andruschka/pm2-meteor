var nodemiral = require('../../');
var printUname = module.exports = nodemiral.taskList('Understanding OS');

printUname.execute('invoke uname', {
  command: 'uname-not-exists -a'
}, function(stdout, stderr) {
  this.uname = stdout;
});

printUname.print('printing uname', {
  message: "\t Uname is: {{uname}}"
});