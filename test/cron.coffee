should = require 'should'
lib = if process.env.MECANO_COV then 'lib-cov' else 'lib'
mecano = require "../#{lib}"
test = require './test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'execute', ->

  rand = Math.random().toString(36).substring(7);
  when_err = Error 'valid when is required'
  cmd_err = Error 'valid cmd is required'

  it 'add a job', (next) ->
    mecano.cron_add
      cmd: "/bin/true #{rand}"
      when: '0 * * * *'
      log: console.log
    , (err, executed) ->
      executed.should.be.ok
      next()

  it 'add the same job', (next) ->
    mecano.cron_add
      cmd: "/bin/true #{rand}"
      when: '0 * * * *'
      log: console.log
    , (err, executed) ->
      executed.should.not.be.ok
      next()

  it 'invalid job: no time', (next) ->
    mecano.cron_add
      cmd: '/remove/me'
      log: console.log
    , (err, executed) ->
      err.should.eql when_err
      next()

  it 'invalid job: invalid time', (next) ->
    mecano.cron_add
      cmd: '/remove/me'
      when: true
      log: console.log
    , (err, executed) ->
      err.should.eql when_err
      next()

  it 'invalid job: no cmd', (next) ->
    mecano.cron_add
      when: '1 2 3 4 5'
      log: console.log
    , (err, executed) ->
      err.should.eql cmd_err
      next()

  it 'invalid job: invalid cmd', (next) ->
    mecano.cron_add
      cmd: ''
      when: '1 2 3 4 5'
      log: console.log
    , (err, executed) ->
      err.should.eql cmd_err
      next()

  it 'remove job', (next) ->
    mecano.cron_delete
      cmd: "/bin/true #{rand}"
      log: console.log
    , (err, executed) ->
      executed.should.be.ok
      next()


  it 'remove the same job', (next) ->
    mecano.cron_delete
      cmd: "/bin/true #{rand}"
      when: '0 * * * *'
      log: console.log
    , (err, executed) ->
      executed.should.not.be.ok
      next()
