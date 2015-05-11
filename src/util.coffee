_ = require 'underscore'
S = require 'string'

util =
  hasType: (object, type) ->
    object.constructor.name == type.name

  checkArgs: (object, allowedTypes) ->
    allowedTypes = [allowedTypes] unless _.isArray allowedTypes
    valid = false
    for type in allowedTypes
      break if valid = @hasType object, type
    unless valid
      allowedTypesString = _.map(allowedTypes, (t) -> t.name).join ', '
      throw new TypeError("expected #{allowedTypesString} but got #{object.constructor.name}")
    true

  escape: (s, chars=['"', "'"], escapeChar="\\") ->
    regexp = new RegExp("([#{chars.join('')}])", 'g')
    s.replace regexp, "#{escapeChar}$1"

  quote: (value, escape=false) ->
    value = value.replace(/"/g, "\\\"") if escape
    "\"#{value}\""

  quoteAll: (values, escape=false) ->
    _.map values, (value) =>
      @quote value, escape

  setOptions: (options, callback) ->
    if _.isFunction(options) && !callback?
      [{}, options]
    else
      [options, callback ? null]

  wrapCallback: (callback, handler) ->
    return unless callback?
    done = callback
    (err, stdout, stderr) ->
      args = handler err, stdout, stderr
      done err, args

module.exports = util
