var SshClient = require('ssh2');

function SSH() {
  var self = this;
  this._client = new SshClient();
  this._client.once('ready', function() {
    self._ready = true;
  });
}

SSH.prototype.connect = function(connInfo) {
  this._client.connect(connInfo);
};

SSH.prototype._onReady = function(callback) {
  if(this._ready) {
    callback();
  } else {
    this._client.once('ready', callback);
  }
};

SSH.prototype.putFile = function(src, dest, options, callback) {
  self = this;
  if(typeof options === 'function') {
    callback = options;
    options = {};
  }

  self._onReady(function() {
    self._client.sftp(onSftp);
  });

  function onSftp(err, sftp) {
    if(err) {
      callback(err);
    } else {
      var totalTransfered = 0;
      var fastPutOptions = {
        step: sendProgressInfo
      };

      sftp.fastPut(src, dest, fastPutOptions, function(err) {
        if(err) {
          callback(err);
        } else {
          callback(null);
        }
      });
    }

    function sendProgressInfo(_tt, chunk, total) {
      totalTransfered += chunk;
      if(options.onProgress) {
        var completedPercentage = (totalTransfered/total) * 100;
        options.onProgress(completedPercentage);
      }
    }
  }
};

SSH.prototype.putContent = function(content, dest, callback) {
  self = this;
  self._onReady(function() {
    self._client.sftp(onSftp);
  });

  var fileHandle;
  var sftp;

  function onSftp(err, _sftp) {
    if(err) {
      callback(err);
    } else {
      sftp = _sftp;
      openFile();
    }
  }

  function openFile() {
    sftp.open(dest, "w+", function(err, handle) {
      if(err) {
        callback(err);
      } else {
        fileHandle = handle;
        writeContent();
      }
    });
  }

  function writeContent() {
    var data = new Buffer(content)
    sftp.write(fileHandle, data, 0, data.length, 0, function(err) {
      if(err) {
        callback(err);
      } else {
        sftp.close(fileHandle, callback);
      }
    });
  }
};

SSH.prototype.execute = function(shellCommand, options, callback) {
  var self = this;
  if(typeof options === 'function') {
    callback = options;
    options = {};
  }

  options.onStdout = options.onStdout || function() {};
  options.onStderr = options.onStderr || function() {};

  self._onReady(function() {
    self._client.exec(shellCommand, onExec);
  });

  function onExec(err, stream) {
    if(err) {
      callback(err);
    } else {
      var context = {stdout: "", stderr: ""};
      stream.on('close', function(code, signal) {
        context.code = code;
        context.signal = signal;
        callback(null, context);
      }).on('data', function(data) {
        data = data.toString();
        context.stdout += data;
        options.onStdout(data);
      }).stderr.on('data', function(data) {
        data = data.toString();
        context.stderr += data;
        options.onStderr(data);
      });
    }
  }
};

SSH.prototype.close = function() {
  this._client.end();
};

module.exports = SSH;