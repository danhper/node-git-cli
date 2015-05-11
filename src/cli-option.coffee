_    = require 'underscore'

Util = require './util'

class CliOption
  constructor: (option, args) ->
    Util.checkArgs option, [Array, String, Object]
    if _.isUndefined(args) && _.isString(option)
      @option = option
      @hasArgs = false
    else
      @_initWithArguments option, args

  _initWithArguments: (option, args) ->
    if _.isUndefined args
      Util.checkArgs option, [Array, Object]
      option =  if _.isArray(option) then [option] else _.pairs(option)
      if option.length != 1
        throw new TypeError("options object should be a single key/value pair")
      [@option, @args] = option[0]
    else
      [@option, @args] = [option, args]
    Util.checkArgs @args, [Array, String, Number, Boolean]
    @args = [@args] unless _.isArray @args
    @args = _.map @args, (a) -> if a == _.isBoolean(a) then '' else a.toString()

    @hasArgs = _.any @args, (a) -> a.length > 0

  toString: ->
    if @hasArgs
      @_formatOptionWithArgs()
    else
      @_formatSimpleOption()

  _formatSimpleOption: ->
    prefix = if @option.length == 1 then '-' else '--'
    prefix + @option

  _formatOptionWithArgs: ->
    argsString = Util.quoteAll(@args, true).join ' '
    if @option.length == 1
      "-#{@option} #{argsString}"
    else
      "--#{@option}=#{argsString}"

module.exports = CliOption
