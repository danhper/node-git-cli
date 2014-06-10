S      = require 'string'
_      = require 'underscore'
path   = require 'path'

errors      = require './errors'
CliCommand  = require './cli-command'
CliOption   = require './cli-option'
Runner      = require './runner'
Util        = require './util'
GitUtil     = require './git-util'

class Repository
  BAD_PATH_MSG = "repository path should point .git directory"

  constructor: (@path) ->
    unless S(@path).endsWith('.git')
      throw new errors.BadRepositoryError(BAD_PATH_MSG)

  @clone: (url, path, options={}) ->
    command = new CliCommand(['git', 'clone'], [url, path], options.cli)
    if options.onSuccess
      success = options.onSuccess
      options.onSuccess = ->
        repository = new Repository("#{path}/.git")
        success repository
    Runner.execute command, options

  add: (files, options) ->
    [options, files] = [files, ['.']] unless options? && _.isArray(files)
    args = []
    Array.prototype.push.apply(args, files)
    command = new CliCommand(['git', 'add'], args, options.cli)
    Runner.execute command, @_createOptions(options)

  status: (options={}) ->
    command = new CliCommand(['git', 'status'], [new CliOption('s')])
    if options.onSuccess
      success = options.onSuccess
      options.onSuccess = (stdout, stderr) =>
        statusInfo = GitUtil.parseStatus(stdout)
        _.each(statusInfo, (f) => f.fullPath = "#{@workingDir()}/#{f.path}")
        success statusInfo
    Runner.execute command, @_createOptions(options)

  diff: (options={}) ->
    args = []
    args.push options.source if options.source?
    args.push options.target if options.target?
    if options.path?
      args.push '--'
      Array.prototype.push.apply args, options.paths


  workingDir: -> path.dirname @path

  _createOptions: (base={}) ->
    _.extend
      cwd: @workingDir()
    , base


module.exports = Repository
