_ = require 'underscore'
S = require 'string'

Util =
  isSameType: (object, type) ->
    object.constructor.name == type.name

  checkArgs: (object, allowedTypes) ->
    allowedTypes = [allowedTypes] unless _.isArray allowedTypes
    valid = false
    for type in allowedTypes
      break if valid = Util.isSameType object, type
    unless valid
      allowedTypesString = _.map(allowedTypes, (t) -> t.name).join ', '
      throw new TypeError("expected #{allowedTypesString} but got #{object.constructor.name}")

  quote: (value) ->
    S(value).ensureLeft("'").ensureRight("'").s

  quoteAll: (values) ->
    _.map values, (value) =>
      @quote value

module.exports = Util
