
path = require 'path'
nikita = require '@nikitajs/engine/src'
{tags, ssh, tmpdir} = require './test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'file.upload', ->

  they 'source is missing', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file.upload
        target: "#{tmpdir}/#{path.basename __filename}"
      .should.be.rejectedWith message: 'NIKITA_SCHEMA_VALIDATION_CONFIG: one error was found in the configuration: #/required config should have required property \'source\'.'

  they 'target is missing', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file.upload
        source: "#{__filename}"
      .should.be.rejectedWith message: 'NIKITA_SCHEMA_VALIDATION_CONFIG: one error was found in the configuration: #/required config should have required property \'target\'.'

  they 'file into a file', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file.upload
        source: "#{__filename}"
        target: "#{tmpdir}/#{path.basename __filename}"
      .should.be.resolvedWith status: true
      @fs.assert
        target: "#{tmpdir}/#{path.basename __filename}"
      @file.upload
        source: "#{__filename}"
        target: "#{tmpdir}/#{path.basename __filename}"
      .should.be.resolvedWith status: false

  they 'file into a directory', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file.upload
        source: "#{__filename}"
        target: "#{tmpdir}"
      .should.be.resolvedWith status: true
      @fs.assert
        target: "#{tmpdir}/#{path.basename __filename}"
      @file.upload
        source: "#{__filename}"
        target: "#{tmpdir}"
      .should.be.resolvedWith status: false
