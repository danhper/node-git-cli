S      = require 'string'
path   = require 'path'

errors      = require './errors'
CliCommand  = require './cli-command'
Runner      = require './runner'


class Repository
  BAD_PATH_MSG = "repository path should point .git directory"

  constructor: (@path) ->
    unless S(@path).endsWith('.git')
      throw new errors.BadRepositoryError(BAD_PATH_MSG)

  @clone: (url, path, options={}) ->
    command = new CliCommand('git', ['clone', url, path], options.cli)
    if options.onSuccess
      success = options.onSuccess
      options.onSuccess = ->
        repository = new Repository("#{path}/.git")
        success repository
    Runner.execute command, options

  workingDir: -> path.dirname @path


module.exports = Repository
