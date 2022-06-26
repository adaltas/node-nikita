
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'file.ini.read', ->

  they 'parse to an object', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      content = user: preference: color: 'rouge'
      await @file.ini
        content: content
        target: "#{tmpdir}/user.ini"
      {data} = await @file.ini.read
        target: "#{tmpdir}/user.ini"
      data.should.eql content
