
import { Writable } from 'node:stream'
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

class MyWritable extends Writable
  constructor: (data) ->
    super()
    @data = data
  _write: (chunk, encoding, callback) ->
    @data.push chunk.toString()
    callback()

describe 'log.cli', ->
  return unless test.tags.posix
  
  describe 'schema', ->
    
    it 'config `end` default to `false`', ->
      nikita.log.cli ({config}) ->
        config.end.should.be.false()

  describe 'handled event', ->
        
    they 'default options', ({ssh}) ->
      data = []
      host = ssh?.host or 'local'
      nikita
        $ssh: ssh
      .log.cli
        colors: false
        stream: new MyWritable data
        time: false
      .call $header: 'h1', ->
        await @call $header: 'h2a', ->
        await @call $header: 'h2b', ->
          await @call $header: 'h3', -> true
      # .wait 200
      .call ->
        data.should.eql [
          "#{host}   h1 : h2a   -\n"
          "#{host}   h1 : h2b : h3   ✔\n"
          "#{host}   h1 : h2b   ✔\n"
          "#{host}   h1   ✔\n"
        ]
    
    they 'pass over actions without header', ({ssh}) ->
      data = []
      host = ssh?.host or 'local'
      nikita
        $ssh: ssh
      .log.cli
        colors: false
        stream: new MyWritable data
        time: false
      .call $header: 'h1', ->
        await @call $header: 'h2a', ->
        await @call  ->
          await @call  ->
            await @call $header: 'h2b', -> true
      # .wait 200
      .call ->
        data.should.eql [
          "#{host}   h1 : h2a   -\n"
          "#{host}   h1 : h2b   ✔\n"
          "#{host}   h1   ✔\n"
        ]

    they 'status boolean', ({ssh}) ->
      data = []
      host = ssh?.host or 'local'
      nikita
        $ssh: ssh
      .log.cli
        colors: false
        stream: new MyWritable data
        time: false
      .call $header: 'a', -> false
      .call $header: 'b', -> true
      .call ->
        data.should.eql [
          "#{host}   a   -\n"
          "#{host}   b   ✔\n"
        ]

    they 'status with shy', ({ssh}) ->
      data = []
      host = ssh?.host or 'local'
      nikita
        $ssh: ssh
      .log.cli
        colors: false
        stream: new MyWritable data
        time: false
      .call $header: 'a', $shy: false, -> true
      .call $header: 'b', $shy: true, -> true
      .call ->
        data.should.eql [
          "#{host}   a   ✔\n"
          "#{host}   b   -\n"
        ]

    they.skip 'status with relax', ({ssh}) ->
      # TODO: see relax tests
      data = []
      host = ssh?.host or 'local'
      nikita
        $ssh: ssh
      .log.cli
        colors: false
        stream: new MyWritable data
        time: false
      , ->
        try await @call header: 'b', relax: false, -> throw Error 'ok'
        catch err
        # @call header: 'b', relax: true, -> throw Error 'ok'
        await @call ->
          data.should.eql [
            "#{host}   c   ✘\n"
            "#{host}   d   ✘\n"
          ]

    they 'bypass disabled', ({ssh}) ->
      data = []
      host = ssh?.host or 'local'
      nikita
        $ssh: ssh
      .log.cli
        colors: false
        stream: new MyWritable data
        time: false
      .call $header: 'a', -> true
      .call $header: 'b', $disabled: false, -> true
      .call $header: 'c', $disabled: true, -> true
      .call $header: 'd', -> true
      .call ->
        data.should.eql [
          "#{host}   a   ✔\n"
          "#{host}   b   ✔\n"
          "#{host}   d   ✔\n"
        ]

    they 'bypass conditionnal', ({ssh}) ->
      data = []
      host = ssh?.host or 'local'
      nikita
        $ssh: ssh
      .log.cli
        colors: false
        stream: new MyWritable data
        time: false
      .call $header: 'a', -> true
      .call $if: true, $header: 'b', -> true
      .call $if: false, $header: 'c',  -> true
      .call $header: 'd', -> true
      .call ->
        data.should.eql [
          "#{host}   a   ✔\n"
          "#{host}   b   ✔\n"
          "#{host}   d   ✔\n"
        ]

  describe 'config', ->

    they 'config.depth', ({ssh}) ->
      data = []
      host = ssh?.host or 'local'
      nikita
        $ssh: ssh
      .log.cli
        colors: false
        depth_max: 2
        stream: new MyWritable data
        time: false
      .call $header: 'h1', ->
        await @call $header: 'h2a', -> false
        await @call $header: 'h2b', ->
          await @call $header: 'h3', -> false
      .call ->
        data.should.eql [
          "#{host}   h1 : h2a   -\n"
          "#{host}   h1 : h2b   -\n"
          "#{host}   h1   -\n"
        ]

    they 'config.divider', ({ssh}) ->
      data = []
      host = ssh?.host or 'local'
      nikita
        $ssh: ssh
      .log.cli
        colors: false
        divider: ' # '
        stream: new MyWritable data
        time: false
      .call $header: 'h1', ->
        await @call $header: 'h2a', ->
        await @call $header: 'h2b', ->
          await @call $header: 'h3', ->
      .call ->
        data.should.eql [
          "#{host}   h1 # h2a   -\n"
          "#{host}   h1 # h2b # h3   -\n"
          "#{host}   h1 # h2b   -\n"
          "#{host}   h1   -\n"
        ]

    they 'config.colors', ({ssh}) ->
      return this.skip() unless process.stdout.isTTY
      data = []
      host = ssh?.host or 'local'
      nikita
        $ssh: ssh
      .log.cli
        colors: true
        stream: new MyWritable data
        time: false
      .call $header: 'a', -> false
      .call $header: 'b', -> true
      .call $header: 'c', $relax: true, -> throw Error 'ok'
      .call ->
        data.should.eql [
          "\u001b[36m\u001b[2m#{host}   a   -\u001b[22m\u001b[39m\n"
          "\u001b[32m#{host}   b   ✔\u001b[39m\n"
          "\u001b[31m#{host}   c   ✘\u001b[39m\n"
        ]

    it 'config.host', ->
      data = []
      nikita
      .log.cli
        colors: false
        host: 'domain.com'
        pad: host: 10, header: 1
        stream: new MyWritable data
        time: false
      .call $header: 'a', -> false
      .call $header: 'b', -> true
      .call $header: 'c', $relax: true, -> throw Error 'ok'
      .call ->
        data.should.eql [
          'domain.com a -\n'
          'domain.com b ✔\n'
          'domain.com c ✘\n'
        ]

    they 'config.pad', ({ssh}) ->
      data = []
      host = ssh?.host or 'local'
      nikita
        $ssh: ssh
      .log.cli
        colors: false
        pad: {host: 14, header: 18}
        stream: new MyWritable data
        time: false
      .call $header: 'h1', ->
        await @call $header: 'h2a', ->
        await @call $header: 'h2b', ->
          await @call $header: 'h3', ->
      .call ->
        data.should.eql [
          "#{host}#{' '.repeat(14 - host.length)} h1 : h2a           -\n"
          "#{host}#{' '.repeat(14 - host.length)} h1 : h2b : h3      -\n"
          "#{host}#{' '.repeat(14 - host.length)} h1 : h2b           -\n"
          "#{host}#{' '.repeat(14 - host.length)} h1                 -\n"
        ]
    
    they 'config.time default behavior', ({ssh}) ->
      data = []
      nikita
        $ssh: ssh
      , ->
        await @log.cli
          stream: new MyWritable data
          colors: false
        await @call $header: 'h1', ->
          await @wait 100
        await @call $header: 'h2', ->
          await @call $header: 'h3', ->
            await @wait 100
          await @wait 100
        await @call ->
          data[0].should.match /h1   -  1\d{2}ms\n/
          data[1].should.match /h2 : h3   -  1\d{2}ms\n/
          data[2].should.match /h2   -  2\d{2}ms\n/

  describe 'session events', ->
          
    they 'when resolved', ({ssh}) ->
      data = []
      host = ssh?.host or 'local'
      await nikita
        $ssh: ssh
      , ->
        await @log.cli
          colors: false
          stream: new MyWritable data
          time: false
        await @call $header: 'h1', -> true
      data.should.eql [
        "#{host}   h1   ✔\n"
        "#{host}      ♥\n"
      ]
              
    they 'when rejected', ({ssh}) ->
      data = []
      host = ssh?.host or 'local'
      try
        await nikita
          $ssh: ssh
        , ->
          await @log.cli
            colors: false
            stream: new MyWritable data
            time: false
          await @call $header: 'h1', -> throw Error 'OK'
      catch err
      data.should.eql [
        "#{host}   h1   ✘\n"
        "#{host}      ✘\n"
      ]
