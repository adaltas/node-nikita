
misc = if process.env.MECANO_COV then require '../lib-cov/misc' else require '../lib/misc'
test = require './test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'iptables', ->

  describe 'stringify', ->
    misc.mode.stringify('544').should.eql '544'
    misc.mode.stringify(0o0744).should.eql '744'
    misc.mode.stringify(0o1744).should.eql '1744'

  describe 'cmpmod', ->

    it 'compare strings of same size', ->
      misc.mode.compare('544', '544').should.be.ok
      misc.mode.compare('544', '322').should.not.be.ok

    it 'compare strings of different sizes', ->
      misc.mode.compare('544', '4544').should.be.ok
      misc.mode.compare('544', '4543').should.not.be.ok
      misc.mode.compare('0322', '322').should.be.ok
      misc.mode.compare('0544', '322').should.not.be.ok

    it 'compare int with string', ->
      misc.mode.compare(0o0744, '744').should.be.ok
      misc.mode.compare(0o0744, '0744').should.be.ok

    it 'compare int with string', ->
      misc.mode.compare('744', 0o0744).should.be.ok
      misc.mode.compare('0744', 0o0744).should.be.ok
