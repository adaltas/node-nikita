
crypto = require 'crypto'
nikita = require '../../../src'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh

describe 'actions.fs.hash', ->
  return unless tags.posix

  they 'error if target does not exist', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.hash
        target: "#{tmpdir}/unkown"
      .should.be.rejectedWith
        code: 'NIKITA_FS_STAT_TARGET_ENOENT'

  they 'a file', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.writeFile "#{tmpdir}/a_file", content: 'some content'
      {hash, status} = await @fs.hash "#{tmpdir}/a_file"
      hash.should.eql '9893532233caff98cd083a116b013c0b'
      status.should.be.true()

  they 'a file with a globing pattern', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.mkdir "#{tmpdir}/test"
      @fs.base.writeFile
        target: "#{tmpdir}/test/a_file"
        content: 'some content'
      {hash} = await @fs.hash "#{tmpdir}/test/a*file"
      hash.should.eql '9893532233caff98cd083a116b013c0b'

  they 'a link', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.writeFile "#{tmpdir}/a_file", content: 'some content'
      @fs.base.symlink
        source: "#{tmpdir}/a_file"
        target: "#{tmpdir}/a_link"
      {hash, status} = await @fs.hash "#{tmpdir}/a_link"
      hash.should.eql '9893532233caff98cd083a116b013c0b'
      status.should.be.true()

  they 'a directory', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.mkdir "#{tmpdir}/a_dir"
      @fs.base.writeFile
        target: "#{tmpdir}/a_dir/file_1"
        content: 'hello 1'
      @fs.base.writeFile
        target: "#{tmpdir}/a_dir/file_2"
        content: 'hello 2'
      {hash, status} = await @fs.hash "#{tmpdir}/a_dir"
      hash.should.eql 'df940215c7446254f1334d923b3053c6'
      status.should.be.true()
          
  they 'throws error if file does not exist', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.hash
        target: "#{__dirname}/does/not/exist"
        relax: true
      , (err, {status}) ->
        err.message.should.eql "Missing File: no file exists for target \"#{__dirname}/does/not/exist\""

  they 'returns the directory md5 when empty', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.base.mkdir "#{tmpdir}/a_dir"
      {hash} = await @fs.hash  "#{tmpdir}/a_dir"
      hash.should.eql crypto.createHash('md5').update('').digest('hex')
    
  describe 'config `hash`', ->

    they 'valid', ({ssh}) ->
      nikita
        ssh: ssh
        tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.base.writeFile "#{tmpdir}/a_file", content: 'some content'
        @fs.hash
          target: "#{tmpdir}/a_file"
          hash: '9893532233caff98cd083a116b013c0b'
          relax: true
        , (err, {status}) ->
          status.should.be.true() unless err

    they 'invalid', ({ssh}) ->
      nikita
        ssh: ssh
        tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.base.writeFile "#{tmpdir}/a_file", content: 'some content'
        @fs.hash
          target: "#{tmpdir}/a_file"
          hash: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
        .should.be.rejectedWith
          code: 'NIKITA_FS_HASH_HASH_NOT_EQUAL'
          message: [
            'NIKITA_FS_HASH_HASH_NOT_EQUAL:'
            'the target hash does not equal the execpted value,'
            'got "9893532233caff98cd083a116b013c0b",'
            'expected "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"'
          ].join ' '
          target: "#{tmpdir}/a_file"
