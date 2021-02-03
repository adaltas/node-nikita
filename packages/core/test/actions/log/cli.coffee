
fs = require 'fs'
nikita = require '../../../src'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

return unless tags.posix

Writable = require('stream').Writable
class MyWritable extends Writable
  constructor: (data) ->
    super()
    @data = data
  _write: (chunk, encoding, callback) ->
    @data.push chunk.toString()
    callback()

describe 'actions.log.cli', ->

  describe 'handled event', ->
        
    they 'default options', ({ssh}) ->
      data = []
      host = ssh?.host or 'localhost'
      nikita
        ssh: ssh
      .log.cli
        colors: false
        stream: new MyWritable data
        time: false
      .call metadata: header: 'h1', ->
        @call metadata: header: 'h2a', ->
        @call metadata: header: 'h2b', ->
          @call metadata: header: 'h3', -> true
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
      host = ssh?.host or 'localhost'
      nikita
        ssh: ssh
      .log.cli
        colors: false
        stream: new MyWritable data
        time: false
      .call metadata: header: 'h1', ->
        @call metadata: header: 'h2a', ->
        @call  ->
          @call  ->
            @call metadata: header: 'h2b', -> true
      # .wait 200
      .call ->
        data.should.eql [
          "#{host}   h1 : h2a   -\n"
          "#{host}   h1 : h2b   ✔\n"
          "#{host}   h1   ✔\n"
        ]

    they 'status boolean', ({ssh}) ->
      data = []
      host = ssh?.host or 'localhost'
      nikita
        ssh: ssh
      .log.cli
        colors: false
        stream: new MyWritable data
        time: false
      .call metadata: header: 'a', -> false
      .call metadata: header: 'b', -> true
      .call ->
        data.should.eql [
          "#{host}   a   -\n"
          "#{host}   b   ✔\n"
        ]

    they 'status with shy', ({ssh}) ->
      data = []
      host = ssh?.host or 'localhost'
      nikita
        ssh: ssh
      .log.cli
        colors: false
        stream: new MyWritable data
        time: false
      .call metadata: header: 'a', shy: false, -> true
      .call metadata: header: 'b', shy: true, -> true
      .call ->
        data.should.eql [
          "#{host}   a   ✔\n"
          "#{host}   b   -\n"
        ]

    they.skip 'status with relax', ({ssh}) ->
      # TODO: see relax tests
      data = []
      host = ssh?.host or 'localhost'
      nikita
        ssh: ssh
      .log.cli
        colors: false
        stream: new MyWritable data
        time: false
      , ->
        try await @call header: 'b', relax: false, -> throw Error 'ok'
        catch err
        # @call header: 'b', relax: true, -> throw Error 'ok'
        @call ->
          console.log 'ok2', data
          data.should.eql [
            "#{host}   c   ✘\n"
            "#{host}   d   ✘\n"
          ]

    they 'bypass disabled', ({ssh}) ->
      data = []
      host = ssh?.host or 'localhost'
      nikita
        ssh: ssh
      .log.cli
        colors: false
        stream: new MyWritable data
        time: false
      .call metadata: header: 'a', -> true
      .call metadata: header: 'b', disabled: false, -> true
      .call metadata: header: 'c', disabled: true, -> true
      .call metadata: header: 'd', -> true
      .call ->
        data.should.eql [
          "#{host}   a   ✔\n"
          "#{host}   b   ✔\n"
          "#{host}   d   ✔\n"
        ]

    they 'bypass conditionnal', ({ssh}) ->
      data = []
      host = ssh?.host or 'localhost'
      nikita
        ssh: ssh
      .log.cli
        colors: false
        stream: new MyWritable data
        time: false
      .call metadata: header: 'a', -> true
      .call if: true, metadata: header: 'b', -> true
      .call if: false, metadata: header: 'c',  -> true
      .call metadata: header: 'd', -> true
      .call ->
        data.should.eql [
          "#{host}   a   ✔\n"
          "#{host}   b   ✔\n"
          "#{host}   d   ✔\n"
        ]

    they 'option depth', ({ssh}) ->
      data = []
      host = ssh?.host or 'localhost'
      nikita
        ssh: ssh
      .log.cli
        colors: false
        depth_max: 2
        stream: new MyWritable data
        time: false
      .call metadata: header: 'h1', ->
        @call metadata: header: 'h2a', -> false
        @call metadata: header: 'h2b', ->
          @call metadata: header: 'h3', -> false
      .call ->
        data.should.eql [
          "#{host}   h1 : h2a   -\n"
          "#{host}   h1 : h2b   -\n"
          "#{host}   h1   -\n"
        ]

    they 'option divider', ({ssh}) ->
      data = []
      host = ssh?.host or 'localhost'
      nikita
        ssh: ssh
      .log.cli
        colors: false
        divider: ' # '
        stream: new MyWritable data
        time: false
      .call metadata: header: 'h1', ->
        @call metadata: header: 'h2a', ->
        @call metadata: header: 'h2b', ->
          @call metadata: header: 'h3', ->
      .call ->
        data.should.eql [
          "#{host}   h1 # h2a   -\n"
          "#{host}   h1 # h2b # h3   -\n"
          "#{host}   h1 # h2b   -\n"
          "#{host}   h1   -\n"
        ]

    they 'option pad', ({ssh}) ->
      data = []
      host = ssh?.host or 'localhost'
      nikita
        ssh: ssh
      .log.cli
        colors: false
        pad: {host: 14, header: 18}
        stream: new MyWritable data
        time: false
      .call metadata: header: 'h1', ->
        @call metadata: header: 'h2a', ->
        @call metadata: header: 'h2b', ->
          @call metadata: header: 'h3', ->
      .call ->
        data.should.eql [
          "#{host}      h1 : h2a           -\n"
          "#{host}      h1 : h2b : h3      -\n"
          "#{host}      h1 : h2b           -\n"
          "#{host}      h1                 -\n"
        ]

    they 'option colors', ({ssh}) ->
      data = []
      host = ssh?.host or 'localhost'
      nikita
        ssh: ssh
      .log.cli
        colors: true
        stream: new MyWritable data
        time: false
      .call metadata: header: 'a', -> false
      .call metadata: header: 'b', -> true
      .call metadata: header: 'c', relax: true, -> throw Error 'ok'
      .call ->
        data.should.eql [
          "\u001b[36m\u001b[2m#{host}   a   -\u001b[22m\u001b[39m\n"
          "\u001b[32m#{host}   b   ✔\u001b[39m\n"
          "\u001b[31m#{host}   c   ✘\u001b[39m\n"
        ]
    
    they 'option time', ({ssh}) ->
      data = []
      nikita
        ssh: ssh
      , ->
        @log.cli
          stream: new MyWritable data
          colors: false
        @call metadata: header: 'h1', ->
          @wait 100
        @call metadata: header: 'h2', ->
          @call metadata: header: 'h3', ->
            @wait 100
          @wait 100
        @call ->
          data[0].should.match /h1   -  1\d{2}ms\n/
          data[1].should.match /h2 : h3   -  1\d{2}ms\n/
          data[2].should.match /h2   -  2\d{2}ms\n/

  describe 'session events', ->
          
    they 'when resolved', ({ssh}) ->
      data = []
      host = ssh?.host or 'localhost'
      await nikita
        ssh: ssh
      , ->
        @log.cli
          colors: false
          stream: new MyWritable data
          time: false
        @call metadata: header: 'h1', -> true
      data.should.eql [
        "#{host}   h1   ✔\n"
        "#{host}      ♥\n"
      ]
              
    they 'when rejected', ({ssh}) ->
      data = []
      host = ssh?.host or 'localhost'
      try
        await nikita
          ssh: ssh
        , ->
          @log.cli
            colors: false
            stream: new MyWritable data
            time: false
          @call metadata: header: 'h1', -> throw Error 'OK'
      catch err
      data.should.eql [
        "#{host}   h1   ✘\n"
        "#{host}      ✘\n"
      ]
