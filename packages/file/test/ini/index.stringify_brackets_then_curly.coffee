
import nikita from '@nikitajs/core'
import utils from '@nikitajs/file/utils'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'file.ini option stringify_brackets_then_curly', ->
  return unless test.tags.posix
  
  # TODO: move to `utils.ini` tests

  they 'call stringify udf', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @file.ini
        stringify: utils.ini.stringify_brackets_then_curly
        target: "#{tmpdir}/user.ini"
        content: user: preference: color: true
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/user.ini"
        content: '[user]\n preference = {\n  color = true\n }\n\n'

  they 'convert array to multiple keys', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      # Create a new file
      {$status} = await @file.ini
        stringify: utils.ini.stringify_brackets_then_curly
        target: "#{tmpdir}/user.ini"
        content: user: preference: language: ['c', 'c++', 'ada']
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/user.ini"
        content: '[user]\n preference = {\n  language = c\n  language = c++\n  language = ada\n }\n\n'
      # Modify an existing file
      # TODO: merge is not supported
