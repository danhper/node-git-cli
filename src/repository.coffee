fs     = require 'fs-extra'
S      = require 'string'
_      = require 'underscore'
path   = require 'path'

errors      = require './errors'
CliCommand  = require './cli-command'
execute     = require('./runner').execute
util        = require './util'
gitUtil     = require './git-util'

class Repository
  BAD_PATH_MSG = "repository path should point .git directory"

  constructor: (@path) ->
    unless S(@path).endsWith('.git')
      throw new errors.BadRepositoryError(BAD_PATH_MSG)

  workingDir: -> path.dirname @path

  _getOptions: (extra={}) ->
    _.assign({cwd: @workingDir()}, extra)

_.each require('./repo-class-methods'), (method, key) ->
  Repository[key] = method

_.each ['stats', 'remote', 'branch', 'remote-actions', 'index-actions'], (module) ->
  _.each require("./#{module}"), (method, key) ->
    Repository.prototype[key] = method

module.exports = Repository
