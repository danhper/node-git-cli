exec = require('child_process').exec

Runner =
  execute: (command, options={}) ->
    exec command.toString(), options, (err, stdout, stderr) ->
      if options.callback?
        options.callback err, stdout, stderr

module.exports = Runner
