_          = require 'underscore'
CliCommand = require './cli-command'
gitUtil    = require './git-util'
util       = require './util'
execute    = require('./runner').execute

exports.currentBranch = (options, callback) ->
  [options, callback] = util.setOptions options, callback
  command = new CliCommand(['git', 'branch'], options)
  execOptions = processResult: (err, stdout) -> gitUtil.parseCurrentBranch stdout
  execute command, @_getOptions(execOptions), callback

exports.branch = (branch, options, callback) ->
  branch = [branch] if _.isString(branch)
  if _.isArray(branch)
    [[options, callback], hasName] = [util.setOptions(options, callback), true]
  else
    [[options, callback], hasName] = [util.setOptions(branch, options), false]
  branch = [] unless hasName
  command = new CliCommand(['git', 'branch'], branch, options)
  execOptions = processResult: (err, stdout) -> gitUtil.parseBranches stdout unless hasName
  execute command, @_getOptions(execOptions), callback
