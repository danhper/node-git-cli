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

  describe '#parseRemote', ->
    it 'should parse remote info', ->
      s = """
        * remote origin
          Fetch URL: git@github.com:tuvistavie/node-git-cli.git
          Push  URL: git@github.com:tuvistavie/node-git-cli.git
          HEAD branch: master
          Remote branch:
            master
          Local branch configured for 'git pull':
            master merges with remote master
          Local ref configured for 'git push':
            master pushes to master (up to date)

          """
      remoteInfo = GitUtil.parseRemote s
      expected =
        fetchUrl: 'git@github.com:tuvistavie/node-git-cli.git'
        pushUrl:  'git@github.com:tuvistavie/node-git-cli.git'
        headBranch: 'master'

      expect(remoteInfo).to.eql expected

  describe '#parseCurrentBranch', ->
    it 'should parse current branch', ->
      s = """
          dev
          facebook_share
          master
          mobile
        * new_design

          """
      currentBranch = GitUtil.parseCurrentBranch s
      expect(currentBranch).to.be 'new_design'

    it 'should return undefined when no current branch', ->
      expect(GitUtil.parseCurrentBranch('')).to.be undefined

  describe '#parseBranches', ->
    it 'should parse branch list', ->
      s = """
          dev
          facebook_share
          master
          mobile
        * new_design

          """
      branches = GitUtil.parseBranches s
      expected = ['dev', 'facebook_share', 'master', 'mobile', 'new_design']
      expect(branches).to.eql expected
