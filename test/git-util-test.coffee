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
    checkStats = (s, expected) ->
      stats = GitUtil.parseShortDiff(s)
      expect(stats).to.be.a Object
      _.each expected, (v, k) ->
        expect(stats).to.have.key k
        expect(stats[k]).to.be v


    it 'should parse singular',  ->
      s = ' 1 file changed, 1 insertion(+), 1 deletion(-)\n'
      expected = { changedFilesNumber: 1, insertions: 1, deletions: 1}
      checkStats s, expected

    it 'should parse plural', ->
      s = ' 2 files changed, 3 insertions(+), 4 deletions(-)'
      expected = { changedFilesNumber: 2, insertions: 3, deletions: 4}
      checkStats s, expected

    it 'should work with only insertions', ->
      s = ' 1 file changed, 3 insertions(+)'
      expected = { changedFilesNumber: 1, insertions: 3, deletions: 0}
      checkStats s, expected

    it 'should work with only deletions', ->
      s = ' 2 files changed, 1 deletion(-)'
      expected = { changedFilesNumber: 2, insertions: 0, deletions: 1}
      checkStats s, expected
