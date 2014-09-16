util       = require './util'
CliCommand = require './cli-command'
execute    = require('./runner').execute
fs         = require 'fs-extra'

exports.init = (path, options, callback) ->
  [options, callback] = util.setOptions options, callback
  fs.ensureDirSync path
  command = new CliCommand('git', ['init', path], options)
  cb = util.wrapCallback callback, (=> new this("#{path}/.git"))
  execute command, {}, cb

exports.clone = (url, path, options, callback) ->
  [options, callback] = util.setOptions options, callback
  command = new CliCommand(['git', 'clone'], [url, path], options)
  cb = util.wrapCallback callback, (=> new this("#{path}/.git"))
  execute command, {}, cb
