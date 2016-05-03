expect = require 'expect.js'

util = require '../src/util'

describe 'util', ->
  describe 'hasType', ->
    it 'should return true on same type', ->
      expect(util.hasType('abc', String)).to.be true
      expect(util.hasType(1, Number)).to.be true
      expect(util.hasType([], Array)).to.be true
      expect(util.hasType({}, Object)).to.be true

    it 'should return false otherwie', ->
      expect(util.hasType('abc', Number)).to.be false
      expect(util.hasType([], Object)).to.be false

  describe 'checkArgs', ->
    it 'should return true when type matches', ->
      expect(util.checkArgs 'abc', String).to.be true

    it 'should return false when any type matches', ->
      expect(util.checkArgs 'abc', [Array, String]).to.be true

    it 'should throw otherwise', ->
      fn = (-> util.checkArgs 'abc', Array)
      expect(fn).to.throwException (e) ->
        expect(e).to.be.a TypeError

      fn = (-> util.checkArgs 'abc', [Array, Object])
      expect(fn).to.throwException (e) ->
        expect(e).to.be.a TypeError

  describe 'quote', ->
    it 'should quote raw argument', ->
      expect(util.quote('foo')).to.be "\"foo\""

    it 'should escape string quotes', ->
      expect(util.quote("foo\"", true)).to.be '"foo\\""'
      expect(util.quote("\"foo\"", true)).to.be '"\\"foo\\""'

  describe 'quoteAll', ->
    it 'should quote all elements', ->
      expect(util.quoteAll(["foo", "bar"])).to.eql ["\"foo\"", "\"bar\""]

  describe 'escape', ->
    it 'should escape quotes by default', ->
      s = "abc'def'ghi\""
      expected = "abc\\'def\\'ghi\\\""
      expect(util.escape(s)).to.eql expected

    it 'should escape given chars', ->
      s = "abcdefg'hi"
      expected = "abc\\def\\g'hi"
      expect(util.escape(s, ['d', 'g'])).to.eql expected

  describe 'setOptions', ->
    it 'should work without options', ->
      [options, callback] = util.setOptions (-> 1)
      expect(options).to.be.a('object')
      expect(callback).to.be.a('function')

    it 'should work with options and callback', ->
      [options, callback] = util.setOptions { force: true }, (-> 1)
      expect(options).to.be.a('object')
      expect(callback).to.be.a('function')
      expect(options.force).to.be true

    it 'should work with options and no callback', ->
      [options, callback] = util.setOptions { force: true }
      expect(options).to.be.a('object')
      expect(callback).to.be null
      expect(options.force).to.be true
