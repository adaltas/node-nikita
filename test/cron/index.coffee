
should = require 'should'
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

###
Note on OSX, by default, I got the message "crontab: no crontab for {user} - using an empty one"

```
crontab -e
30 * * * * /usr/bin/curl --silent --compressed http://www.adaltas.com
crontab -l
```
###

describe 'cron', ->

  config = test.config()
  return if config.disable_cron
  rand = Math.random().toString(36).substring(7);

  they 'add a job', (ssh, next) ->
    nikita
      ssh: ssh
    .service 'cronie'
    .cron.add
      cmd: "/bin/true #{rand}/toto - *.mp3"
      when: '0 * * * *'
    , (err, status) ->
      status.should.be.true()
    .cron.add
      cmd: "/bin/true #{rand}/toto - *.mp3"
      when: '0 * * * *'
    , (err, status) ->
      status.should.be.false()
    .cron.remove
      cmd: "/bin/true #{rand}/toto - *.mp3"
      when: '0 * * * *'
    , (err, status) ->
      status.should.be.true()
    .cron.remove
      cmd: "/bin/true #{rand}/toto - *.mp3"
      when: '0 * * * *'
    , (err, status) ->
      status.should.be.false()
    .promise()

  describe 'match', ->

    they 'regexp', (ssh, next) ->
      nikita
        ssh: ssh
      .service 'cronie'
      .cron.add
        cmd: "/bin/true #{rand}"
        when: '0 * * * *'
        match: '.*bin.*'
      , (err, status) ->
        status.should.be.true()
      .cron.add
        cmd: "/bin/false #{rand}"
        when: '0 * * * *'
        match: /.*bin.*/
        diff: (diff) ->
          diff.should.eql [
            { count: 1, added: undefined, removed: true, value: "0 * * * * /bin/false #{rand}" }
            { count: 1, added: true, removed: undefined, value: "0 * * * * /bin/true #{rand}" }
          ]
      , (err, status) ->
        status.should.be.true() unless err
      .cron.add
        cmd: "/bin/false #{rand}"
        when: '0 * * * *'
        match: /.*bin.*/
      , (err, status) ->
        status.should.be.false() unless err
      .cron.remove
        cmd: "/bin/false #{rand}"
        when: '0 * * * *'
      .then next

    they 'string', (ssh, next) ->
      nikita
        ssh: ssh
      .service 'cronie'
      .cron.add
        cmd: "/bin/true #{rand}"
        when: '0 * * * *'
        match: '.*bin.*'
      , (err, status) ->
        status.should.be.true() unless err
      .cron.add
        cmd: "/bin/false #{rand}"
        when: '0 * * * *'
        match: '.*bin.*'
        diff: (diff) ->
          diff.should.eql [
            { count: 1, added: undefined, removed: true, value: "0 * * * * /bin/false #{rand}" }
            { count: 1, added: true, removed: undefined, value: "0 * * * * /bin/true #{rand}" }
          ]
      , (err, status) ->
        status.should.be.true() unless err
      .cron.add
        cmd: "/bin/false #{rand}"
        when: '0 * * * *'
        match: '.*bin.*'
      , (err, status) ->
        status.should.be.false() unless err
      .cron.remove
        cmd: "/bin/false #{rand}"
        when: '0 * * * *'
      .then next

  describe 'error', ->

    they 'invalid job: no time', (ssh, next) ->
      nikita
        ssh: ssh
      .service 'cronie'
      .cron.add
        cmd: '/remove/me'
        relax: true
      , (err) ->
        err.message.should.eql 'valid when is required'
      .then -> next()

    they 'invalid job: invalid time', (ssh, next) ->
      nikita
        ssh: ssh
      .service 'cronie'
      .cron.add
        cmd: '/remove/me'
        when: true
        relax: true
      , (err) ->
        err.message.should.eql 'valid when is required'
      .then -> next()

    they 'invalid job: no cmd', (ssh, next) ->
      nikita
        ssh: ssh
      .service 'cronie'
      .cron.add
        when: '1 2 3 4 5'
        relax: true
      , (err) ->
        err.message.should.eql 'valid cmd is required'
      .then -> next()

    they 'invalid job: invalid cmd', (ssh, next) ->
      nikita
        ssh: ssh
      .service 'cronie'
      .cron.add
        cmd: ''
        when: '1 2 3 4 5'
        relax: true
      , (err) ->
        err.message.should.eql 'valid cmd is required'
      .then -> next()

    they 'invalid job: invalid cmd to exec', (ssh, next) ->
      nikita
        ssh: ssh
      .service 'cronie'
      .cron.add
        cmd: 'azertyytreza'
        when: '1 2 3 4 5'
        exec: true
        relax: true
      , (err, added) ->
        err.code.should.eql 127
        next()
