exec = require('child_process').exec
Promise = require('./config').Promise

Runner =
  execute: (command, options, callback) ->
    new Promise (resolve, reject) ->
      exec command.toString(), options, (err, stdout, stderr) ->
        result = if options.processResult then options.processResult(err, stdout, stderr) else stdout
        if callback?
          callback(err, result, stderr)
        if err?
          reject(err, result, stderr)
        else
          resolve(result, stderr)

module.exports = Runner
