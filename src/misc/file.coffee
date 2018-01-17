
ssh2fs = require 'ssh2-fs'
crypto = require 'crypto'
exec = require 'ssh2-exec'
each = require 'each'
fs = require 'fs'
glob = require './glob'
rimraf = require 'rimraf'

module.exports = file =
  copyFile: (ssh, source, target, callback) ->
    console.log 'deprecated, use nikita.fs.copy instead'
    s = (ssh, callback) ->
      unless ssh
      then callback null, fs
      else ssh.sftp callback
    s ssh, (err, fs) ->
      return callback err if err
      rs = fs.createReadStream source
      ws = rs.pipe fs.createWriteStream target
      ws.on 'finish', ->
        fs.end() if fs.end
        modified = true
        callback()
      ws.on 'error', (err) ->
        if (!ssh and err.code is 'ENOENT') or (ssh and err.code is 2)
          if err.code is 2
            err.code = 'ENOENT'
            err.errno = -2
            err.syscall = 'open'
            err.path = target
          err.message = "Invalid Target: no such file or directory, open #{JSON.stringify target}"
        fs.end() if fs.end
        callback err
  ###
  Compare modes
  -------------
  ###
  copy: (ssh, source, target, callback) ->
    unless ssh
      source = fs.createReadStream(u.pathname)
      source.pipe target
      target.on 'close', callback
      target.on 'error', callback
    else
      # todo: use cp to copy over ssh
      callback Error 'Copy over SSH not yet implemented'
  ###
  `files.compare(files, callback)`
  --------------------------------
  Compare the hash of multiple file. Return the file md5 
  if the file are the same or false otherwise.
  ###
  compare: (ssh, files, callback) ->
    return callback Error 'Minimum of 2 files' if files.length < 2
    result = null
    each files
    .call (f, next) ->
      file.hash ssh, f, (err, md5) ->
        return next err if err
        if result is null
          result = md5 
        else if result isnt md5
          result = false 
        next()
    .next (err) ->
      return callback err if err
      callback null, result
  compare_hash: (ssh1, file1, ssh2, file2, algo, callback) ->
    file.hash ssh1, file1, algo, (err, hash1) ->
      return callback err if err
      file.hash ssh2, file2, algo, (err, hash2) ->
        err = null if err?.code is 'ENOENT'
        return callback err if err
        callback null, hash1 is hash2, hash1, hash2
  ###
  `files.hash(ssh, file, [algorithm], callback)`
  -----------------------------------------
  Retrieve the hash of a supplied file in hexadecimal 
  form. If the provided file is a directory, the returned hash 
  is the sum of all the hashs of the files it recursively 
  contains. The default algorithm to compute the hash is md5.

  Throw an error if file does not exist unless it is a directory.

      file.hash ssh, '/path/to/file', (err, md5) ->
        md5.should.eql '287621a8df3c3f6c99c7b7645bd09ffd'

  ###
  hash: (ssh, file, algorithm, callback) ->
    if arguments.length is 3
      callback = algorithm
      algorithm = 'md5'
    hasher = (ssh, path, callback) ->
      shasum = crypto.createHash algorithm
      unless ssh
        ssh2fs.createReadStream ssh, path, (err, stream) ->
          return callback err if err
          stream
          .on 'data', (data) ->
            shasum.update data
          .on 'error', (err) ->
            return callback() if err.code is 'EISDIR'
            callback err
          .on 'end', ->
            callback err, shasum.digest 'hex'
      else
        ssh2fs.stat ssh, path, (err, stat) ->
          return callback err if err
          return callback() if stat.isDirectory()
          exec
            cmd: """
            which openssl >/dev/null || exit 2
            openssl dgst -#{algorithm} #{path} | sed 's/^.* \\([a-z0-9]*\\)$/\\1/g'
            """
            ssh: ssh
            trim: true
          , (err, stdout, stderr) ->
            err = Error "Command does not exist: openssl" if err?.code is 2
            callback err, stdout?.trim(), stderr?.trim()
    hashs = []
    ssh2fs.stat ssh, file, (err, stat) ->
      if err?.code is 'ENOENT'
        err = Error "Does not exist: #{file}"
        err.code = 'ENOENT'
        return callback err
      return callback err if err
      if stat.isFile()
        return hasher ssh, file, callback
      else if stat.isDirectory()
        compute = (files) ->
          files.sort()
          each files
          .call (item, next) ->
            hasher ssh, item, (err, h) ->
              return next err if err
              hashs.push h if h?
              next()
          .next (err) ->
            return callback err if err
            switch hashs.length
              when 0
                if stat.isFile() 
                then callback Error "Does not exist: #{file}"
                else callback null, crypto.createHash(algorithm).update('').digest('hex')
              when 1
                return callback null, hashs[0]
              else
                hashs = crypto.createHash(algorithm).update(hashs.join('')).digest('hex')
                return callback null, hashs
        glob ssh, "#{file}/**", (err, files) ->
          return callback err if err
          compute files
      else
        callback Error "File type not supported"
  ###
  remove(ssh, path, callback)
  ---------------------------
  Remove a file or directory
  ###
  remove: (ssh, path, callback) ->
    unless ssh
      rimraf path, callback
    else
      # Not very pretty but fast and no time to try make a version of rimraf over ssh
      child = exec ssh, "rm -rf #{path}"
      child.on 'exit', (code) ->
        callback null, code
