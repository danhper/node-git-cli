GitUtil =
  parseStatus: (statusStr) ->
    files = []

    for line in statusStr.trim().split('\n')
      [type, file] = line.split(' ')
      switch type
        when '??' then status.untrackedFiles.push(file)
        when 'M' then status.editedFiles.push(file)
        when 'A' then status.addedFiles.push(file)

    status

module.exports = GitUtil
