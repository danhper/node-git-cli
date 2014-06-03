expect = require 'expect.js'

Util = require '../src/util'

describe 'Util', ->
  describe 'hasType', ->
    it 'should return true on same type', ->
      expect(Util.hasType('abc', String)).to.be true
      expect(Util.hasType(1, Number)).to.be true
      expect(Util.hasType([], Array)).to.be true
      expect(Util.hasType({}, Object)).to.be true

    it 'should return false otherwie', ->
      expect(Util.hasType('abc', Number)).to.be false
      expect(Util.hasType([], Object)).to.be false

  describe 'checkArgs', ->
    it 'should return true when type matches', ->
      expect(Util.checkArgs 'abc', String).to.be true

    it 'should return false when any type matches', ->
      expect(Util.checkArgs 'abc', [Array, String]).to.be true

    it 'should throw otherwise', ->
      fn = (-> Util.checkArgs 'abc', Array)
      expect(fn).to.throwException (e) ->
        expect(e).to.be.a TypeError

      fn = (-> Util.checkArgs 'abc', [Array, Object])
      expect(fn).to.throwException (e) ->
        expect(e).to.be.a TypeError

  describe 'quote', ->
    it 'should quote raw argument', ->
      expect(Util.quote('foo')).to.be "'foo'"

    it 'should escape string quotes', ->
      expect(Util.quote("foo'")).to.be "'foo\\''"
      expect(Util.quote("'foo'")).to.be "'\\'foo\\''"

  describe 'quoteAll', ->
    it 'should quote all elements', ->
      expect(Util.quoteAll(["foo", "bar"])).to.eql ["'foo'", "'bar'"]
