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
    regexp = /(\d+) files changed, (?:(\d+) insertion\(\+\), )?(?:(\d+) deletion\(-\))/
    result = regexp.exec diffStr

    if result?
      stats = _.map result[1..], (v) -> parseInt(v, 10)
    else
      stats = [0, 0, 0]

    {
      changedFilesNumber: stats[0]
      insertions: stats[1]
      deletions: stats[2]
    }


  parseLog: (logStr) ->
    logStr = '[' + logStr[0...-1] + ']'
    JSON.parse logStr


module.exports = GitUtil
