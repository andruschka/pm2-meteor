module.exports = function(nodemiral) {
  nodemiral.registerTask('copy', copy);
  nodemiral.registerTask('execute', execute);
  nodemiral.registerTask('executeScript', executeScript);
  nodemiral.registerTask('print', print);
};

function copy(session, options, callback, varsMapper) {
  session.copy(options.src, options.dest, options, sendCallback(callback, varsMapper));
}

function execute(session, options, callback, varsMapper) {
  session.execute(options.command, sendCallback(callback, varsMapper));
}

function executeScript(session, options, callback, varsMapper) {
  session.executeScript(options.script, options, sendCallback(callback, varsMapper));
}

function print(session, options, callback, varsMapper) {
  console.log(options.message);
  callback();
}

function sendCallback(callback, varsMapper) {
  return function(err, code, logs) {
    if (err) {
      callback(err);
    } else if(code !== 0) {
      
      var errorMessage = '\n-----------------------------------STDERR-----------------------------------\n';
      errorMessage += tail(logs.stderr);
      errorMessage += (errorMessage[errorMessage.length-1] != '\n')? '\n' : "";
      errorMessage += '-----------------------------------STDOUT-----------------------------------\n';
      errorMessage += tail(logs.stdout);
      errorMessage += (errorMessage[errorMessage.length-1] != '\n')? '\n' : "";
      errorMessage += '----------------------------------------------------------------------------';

      callback(new Error(errorMessage));
    } else {
      if(varsMapper) {
        varsMapper(applyTrim(logs.stdout), applyTrim(logs.stderr));
      }
      callback();
    }
  };

  function applyTrim(str) {
    if(str) {
      return str.trim();
    } else {
      return str;
    }
  }

  function tail(str) {
    if(str) {
      return str.substring(str.length-1000);
    } else {
      return "";
    }
  }
}