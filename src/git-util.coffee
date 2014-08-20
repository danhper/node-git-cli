_ = require 'underscore'

GitUtil =
  parseStatus: (statusStr) ->
    files = []

    for line in statusStr.split('\n')
      continue if line.trim() == ''
      [type, path] = [line.substring(0, 2), line.substring(3)]
      [type, tracked] = if type[0] == ' ' then [type[1], false] else [type[0], true]
      switch type
        when '?' then [status, tracked] = ['added', false]
        when 'M' then status = 'modified'
        when 'A' then status = 'added'
        when 'D' then status = 'removed'
      files.push
        path: path
        status: status
        tracked: tracked

    files

  parseShortDiff: (diffStr) ->
    diffStr = diffStr.trim()
    regexp = /(\d+) files? changed(?:, (\d+) insertions?\(\+\))?(?:, (\d+) deletions?\(-\))?/
    result = regexp.exec diffStr

    if result?
      stats = _.map result[1..], (v) -> (if v then parseInt(v, 10) else 0)
    else
      stats = [0, 0, 0]

    {
      changedFilesNumber: stats[0]
      insertions: stats[1]
      deletions: stats[2]
    }

  parseLog: (logStr) ->
    logStr = logStr.replace /"},\n/g, '"},'  # remove linebreaks between commits
    logStr = logStr.replace /\n/g, '\\n'     # replace linebreaks in messages
    logStr = '[' + logStr[0...-1] + ']'      # remove last comma
    logs = JSON.parse logStr
    _.each logs, (log) ->
      log.date = new Date(Date.parse(log.date))
    logs

  parseRemote: (remoteStr) ->
    remoteStr = remoteStr.trim()

    fetchUrl: /\s+Fetch URL: (.*?)\n/.exec(remoteStr)?[1]
    pushUrl: /\s+Push  URL: (.*?)\n/.exec(remoteStr)?[1]
    headBranch: /\s+HEAD branch: (.*?)\n/.exec(remoteStr)?[1]

  parseCurrentBranch: (branches) ->
    branches = branches.trim().split '\n'
    branch = _.find branches, (b) -> b[0] == '*'
    if branch? then branch.substring(2) else undefined

  parseBranches: (branches) ->
    branches = branches.trimRight().split '\n'
    _.map branches, (b) -> b.substring(2)


module.exports = GitUtil
