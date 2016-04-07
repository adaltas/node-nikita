
ssh2fs = require 'ssh2-fs'
crypto = require 'crypto'
exec = require 'ssh2-exec'
each = require 'each'
glob = require './glob'

module.exports = file =
  compare_hash: (ssh1, file1, ssh2, file2, algo, callback) ->
    file.hash ssh1, file1, algo, (err, hash1) ->
      return callback err if err
      file.hash ssh2, file2, algo, (err, hash2) ->
        err = null if err?.code is 'ENOENT'
        return callback err if err
        callback null, hash1 is hash2, hash1, hash2
  ###
  `files.hash(file, [algorithm], callback)`
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
      if not ssh
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
          # return callback null, crypto.createHash(algorithm).update('').digest('hex') if stat.isDirectory()
          exec
            cmd: "openssl #{algorithm} #{path}"
            ssh: ssh
          , (err, stdout) ->
            callback err if err
            callback err, /.*\s([\w\d]+)$/.exec(stdout.trim())[1]
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
          .then (err) ->
            return callback err if err
            switch hashs.length
              when 0
                if stat.isFile() 
                then callback new Error "Does not exist: #{file}"
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
