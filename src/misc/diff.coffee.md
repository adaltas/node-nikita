
# Diff

Report the difference between 2 strings.

    module.exports = (source, target, options) ->
      return unless options.diff
      lines = diff.diffLines target, source
      options.diff lines if typeof options.diff is 'function'
      if options.stdout
        count_added = count_removed = 0
        padsize = Math.ceil(lines.length/10)
        for line in lines
          continue if line.value is null
          if not line.added and not line.removed
            count_added++; count_removed++; continue
          ls = string.lines line.value
          if line.added
            for line in ls
              count_added++
              options.stdout.write "#{pad padsize, ''+(count_added)} + #{line}\n"
          else
            for line in ls
              count_removed++
              options.stdout.write "#{pad padsize, ''+(count_removed)} - #{line}\n"

## Dependencies

    pad = require 'pad'
    diff = require 'diff'
    string = require './string'


