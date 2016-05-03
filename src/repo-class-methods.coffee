util       = require './util'
CliCommand = require './cli-command'
execute    = require('./runner').execute
fs         = require 'fs-extra'

exports.init = (path, options, callback) ->
  [options, callback] = util.setOptions options, callback
  fs.ensureDirSync path
  command = new CliCommand(['git', 'init'], path, options)
  execOptions = processResult: (=> new this("#{path}/.git"))
  execute command, execOptions, callback

exports.clone = (url, path, options, callback) ->
  [options, callback] = util.setOptions options, callback
  command = new CliCommand(['git', 'clone'], [url, path], options)
  execOptions = processResult: (=> new this("#{path}/.git"))
  execute command, execOptions, callback
