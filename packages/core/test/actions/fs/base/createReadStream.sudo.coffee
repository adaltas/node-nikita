
nikita = require '../../../../src'
{tags, config} = require '../../../test'
they = require('mocha-they')(config)
exec = require 'ssh2-exec/promise'

return unless tags.sudo

describe 'actions.fs.base.createReadStream.sudo', ->

  they 'read file', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
      $sudo: true
    , ({metadata: {tmpdir}, ssh}) ->
      await exec ssh, """
      echo -n 'hello' | sudo tee #{tmpdir}/a_file
      """
      buffers = []
      await @fs.base.createReadStream
        stream: (rs) ->
          rs.on 'readable', ->
            while buffer = rs.read()
              buffers.push buffer
        target: "#{tmpdir}/a_file"
      Buffer.concat(buffers).toString().should.eql 'hello'
  
