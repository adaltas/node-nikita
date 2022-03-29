
nikita = require '../../../../src'
{tags, config} = require '../../../test'
they = require('mocha-they')(config)


describe 'actions.fs.base.writeFile.sudo', ->
  return unless tags.sudo

  they 'owner is root', ({ssh}) ->
    nikita
      $ssh: ssh
      $templated: true
      $tmpdir: true
      $sudo: true
    , ->
      await @fs.base.writeFile
        target: "{{parent.metadata.tmpdir}}/a_file"
        content: 'some content'
      {stats} = await @fs.base.stat "{{parent.metadata.tmpdir}}/a_file"
      stats.uid.should.eql 0

      
