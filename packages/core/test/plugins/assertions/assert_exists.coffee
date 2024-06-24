
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'plugin.assertions assert_exists', ->
  return unless test.tags.posix

  they 'success if file exists', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      @fs.writeFile
        $assert_exists: "#{tmpdir}/a_file"
        content: ''
        target: "#{tmpdir}/a_file"
      .should.be.resolved()

  they 'success all files exists', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      @call
        $assert_exists: [
          "#{tmpdir}/file_1"
          "#{tmpdir}/file_2"
        ]
      , ->
        await @fs.writeFile
          content: ''
          target: "#{tmpdir}/file_1"
        await @fs.writeFile
          content: ''
          target: "#{tmpdir}/file_2"
      .should.be.resolved()

  they 'error if file missing', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      @call
        $assert_exists: "#{tmpdir}/a_file"
        $handler: (->)
      .should.be.rejected()
