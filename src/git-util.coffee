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

module.exports = GitUtil
