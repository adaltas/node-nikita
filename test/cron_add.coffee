
should = require 'should'
mecano = require "../src"
test = require './test'
they = require 'ssh2-they'

###
Note on OSX, by default i got the message "crontab: no crontab for {user} - using an empty one"

```
crontab -e
30 * * * * /usr/bin/curl --silent --compressed http://www.adaltas.com
:wq
crontab -l
```
###

describe 'cron', ->

  rand = Math.random().toString(36).substring(7);

  they 'add a job', (ssh, next) ->
    mecano
      ssh: ssh
    .cron_add
      cmd: "/bin/true #{rand}"
      when: '0 * * * *'
    , (err, executed) ->
      executed.should.be.true unless err
    .cron_add
      cmd: "/bin/true #{rand}"
      when: '0 * * * *'
    , (err, executed) ->
      executed.should.be.false unless err
    .cron_remove
      cmd: "/bin/true #{rand}"
      when: '0 * * * *'
    .then next

  describe 'error', ->

    they 'invalid job: no time', (ssh, next) ->
      mecano
        ssh: ssh
      .cron_add
        cmd: '/remove/me'
      , (err, executed) ->
        err.message.should.eql 'valid when is required'
        next()

    they 'invalid job: invalid time', (ssh, next) ->
      mecano
        ssh: ssh
      .cron_add
        cmd: '/remove/me'
        when: true
      , (err, executed) ->
        err.message.should.eql 'valid when is required'
        next()

    they 'invalid job: no cmd', (ssh, next) ->
      mecano
        ssh: ssh
      .cron_add
        when: '1 2 3 4 5'
      , (err, executed) ->
        err.message.should.eql 'valid cmd is required'
        next()

    they 'invalid job: invalid cmd', (ssh, next) ->
      mecano
        ssh: ssh
      .cron_add
        cmd: ''
        when: '1 2 3 4 5'
      , (err, executed) ->
        err.message.should.eql 'valid cmd is required'
        next()
