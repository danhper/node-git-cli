_      = require 'underscore'
expect = require 'expect.js'

GitUtil = require '../src/git-util'

describe 'GitUtil', ->
  describe '#parseStatus', ->
    it 'should parse tracked changes', ->
      s = """
           D LICENSE
           M src/git-util.coffee
          ?? test/git-util-test.coffee
          """
      changes = GitUtil.parseStatus(s)
      expect(changes.length).to.be 3
      expected = [
        { status: 'removed', tracked: false, path: 'LICENSE' }
        { status: 'modified', tracked: false, path: 'src/git-util.coffee' }
        { status: 'added', tracked: false, path:  'test/git-util-test.coffee' }
      ]

      _.each expected, (expectedChanges, index) ->
        _.each expectedChanges, (v, k) ->
          expect(changes[index][k]).to.be v
