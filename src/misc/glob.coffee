
path = require 'path'
{Minimatch} = require 'minimatch'
exec = require 'ssh2-exec'
string = require './string'

getprefix = (pattern) ->
  prefix = null
  n = 0
  while typeof pattern[n] is "string" then n++
  # now n is the index of the first one that is *not* a string.
  # see if there's anything else
  switch n
    # if not, then this is rather simple
    when pattern.length
      prefix = pattern.join '/'
      return prefix
    when 0
      # pattern *starts* with some non-trivial item.
      # going to readdir(cwd), but not include the prefix in matches.
      return null
    else
      # pattern has some string bits in the front.
      # whatever it starts with, whether that's "absolute" like /foo/bar,
      # or "relative" like "../baz"
      prefix = pattern.slice 0, n
      prefix = prefix.join '/'
      return prefix

###
Important: for now, only the "dot" options has been tested.
###

module.exports = (ssh, pattern, options, callback) ->
  if arguments.length is 3
    callback = options
    options = {}
  pattern = path.normalize pattern
  minimatch = new Minimatch pattern, options
  cmd = "find"
  for s in minimatch.set
    prefix = getprefix s
    cmd += " #{prefix}"
  child = exec ssh, cmd, shell: true#, timeout: 0, maxBuffer: 2000*1024
  stdout = []
  child.stdout.on 'data', (data) ->
    stdout.push data.toString()
  child.on 'error', callback
  child.on 'close', (code) ->
    files = string.lines stdout.join('').trim()
    files = files.filter (file) ->
      minimatch.match file
    for s in minimatch.set
      n = 0
      while typeof s[n] is "string" then n++
      if s[n] is Minimatch.GLOBSTAR
        prefix = getprefix s
        files.unshift prefix if prefix
    callback null, files
