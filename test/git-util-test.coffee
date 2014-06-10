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

  describe '#parseShortDiff', ->
    s = ' 2 files changed, 1 insertion(+), 1 deletion(-)\n'
    stats = GitUtil.parseShortDiff(s)
    expect(stats).to.be.a Object
    _.each { changedFilesNumber: 2, insertions: 1, deletions: 1}, (v, k) ->
      expect(stats).to.have.key k
      expect(stats[k]).to.be v
