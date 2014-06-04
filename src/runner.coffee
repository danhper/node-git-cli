ChildProcess = require('child_process')

Runner =
  execute: (command, options={}) ->
    ChildProcess.exec command.toString(), options, (error, stdout, stderr) ->
      if error != null && options.onError
        options.onError error
      else if error == null && options.onSuccess
        options.onSuccess(stdout, stderr)

module.exports = Runner
