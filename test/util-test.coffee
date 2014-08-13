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
      expect(Util.quote("foo'", true)).to.be "'foo\\''"
      expect(Util.quote("'foo'", true)).to.be "'\\'foo\\''"

  describe 'quoteAll', ->
    it 'should quote all elements', ->
      expect(Util.quoteAll(["foo", "bar"])).to.eql ["'foo'", "'bar'"]

  describe 'escape', ->
    it 'should escape quotes by default', ->
      s = "abc'def'ghi\""
      expected = "abc\\'def\\'ghi\\\""
      expect(Util.escape(s)).to.eql expected

    it 'should escape given chars', ->
      s = "abcdefg'hi"
      expected = "abc\\def\\g'hi"
      expect(Util.escape(s, ['d', 'g'])).to.eql expected

  describe 'setOptions', ->
    it 'should work without options', ->
      options = Util.setOptions (-> 1)
      expect(options).to.be.a('object')
      expect(options.callback).to.be.a('function')

    it 'should work with options and callback', ->
      options = Util.setOptions { force: true }, (-> 1)
      expect(options).to.be.a('object')
      expect(options.callback).to.be.a('function')
      expect(options.force).to.be true

    it 'should work with options and no callback', ->
      options = Util.setOptions { force: true }
      expect(options).to.be.a('object')
      expect(options.callback).to.be null
      expect(options.force).to.be true
