exec = require('child_process').exec

Runner =
  execute: (command, options, callback) ->
    exec command.toString(), options, (err, stdout, stderr) ->
      if callback?
        callback err, stdout, stderr

module.exports = Runner
