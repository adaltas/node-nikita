
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'actions.fs.readFile', ->
  return unless test.tags.posix

  they 'argument `target`', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: 'hello'
      @fs.readFile "{{parent.metadata.tmpdir}}/a_file"
      # .should.be.finally.containEql data: Buffer.from 'hello'
      .should.be.finally.containEql data: Buffer.from 'hello'

  they 'config `encoding`', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: 'hello'
      @fs.readFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        encoding: 'ascii'
      .should.be.finally.containEql data: 'hello'

  they 'config `trim`', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
    , ->
      await @fs.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: '  hello\n  '
      @fs.readFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        encoding: 'ascii'
        trim: true
      .should.be.finally.containEql data: 'hello'

  describe 'config `format`', ->

    they 'as udf', ({ssh}) ->
      nikita
        $ssh: ssh
        $templated: true
        $tmpdir: true
      , ->
        await @fs.writeFile
          target: "{{parent.metadata.tmpdir}}/a_file"
          content: 'This is my precious.'
        {data} = await @fs.readFile
          target: "{{parent.metadata.tmpdir}}/a_file"
          encoding: 'ascii'
          format: ({data}) => /^.*\s(\w+)\.$/.exec(data.trim())[1]
        data.should.eql 'precious'

    they 'as json without encoding', ({ssh}) ->
      nikita
        $ssh: ssh
        $templated: true
        $tmpdir: true
      , ->
        await @fs.writeFile
          target: "{{parent.metadata.tmpdir}}/a_file"
          content: '{"key": "value"}'
        {data} = await @fs.readFile
          target: "{{parent.metadata.tmpdir}}/a_file"
          format: 'json'
        data.should.eql key: 'value'

  describe 'error', ->

    they 'forward errors from createReadStream', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.readFile "#{tmpdir}/whereareu"
        .should.be.rejectedWith
          message: "NIKITA_FS_CRS_TARGET_ENOENT: fail to read a file because it does not exist, location is \"#{tmpdir}/whereareu\"."
          errno: -2
          code: 'NIKITA_FS_CRS_TARGET_ENOENT'
          syscall: 'open'
          path: "#{tmpdir}/whereareu"
