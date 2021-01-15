
nikita = require '@nikitajs/engine/lib'
{tags, config} = require './test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'file.cson', ->

  they 'stringify content to target', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/target.cson"
        content: 'doent have to be valid cson'
      @file.cson
        target: "#{tmpdir}/target.cson"
        content: user: 'torval'
      .should.be.finally.containEql status: true
      @fs.assert
        target: "#{tmpdir}/target.cson"
        content: 'user: \"torval\"'

  they 'merge target', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/target.cson"
        content: '"user": "linus"\n"merge": true'
      @file.cson
        target: "#{tmpdir}/target.cson"
        content: 'user': 'torval'
        merge: true
      .should.be.finally.containEql status: true
      @fs.assert
        target: "#{tmpdir}/target.cson"
        content: 'user: \"torval\"\nmerge: true'

  they 'merge target which does not exists', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file.cson
        target: "#{tmpdir}/target.cson"
        content: 'user': 'torval'
        merge: true
      .should.be.finally.containEql status: true
      @fs.assert
        target: "#{tmpdir}/target.cson"
        content: 'user: \"torval\"'
