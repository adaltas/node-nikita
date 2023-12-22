
import each from 'each'
import nikita from '@nikitajs/core'
import test from '../../test.coffee'

describe 'session.scheduler.error', ->
  return unless test.tags.api

  describe 'scheduler:in', ->

    it 'scheduling new action once closed', ->
      prom = null
      await nikita ->
        prom = each Array.from({length: 3}), true, (_, i) =>
          @call ->
            new Promise (resolve) ->
              history.push "#{i}:start"
              setTimeout ->
                history.push "#{i}:end"
                resolve()
              , 100
        true
      prom.should.be.rejectedWith [
        'NIKITA_SCHEDULER_CLOSED:'
        'cannot schedule new items when closed.'
      ].join(' ')

    it 'cascaded rejected promise', ->
      nikita ->
        @call ->
          @call ->
            new Promise (resolve, reject) ->
              reject Error 'catchme'
        .should.be.rejectedWith 'catchme'

    it 'cascaded thrown error', ->
      nikita ->
        @call ->
          @call ->
            await @call ->
              new Promise (resolve, reject) ->
                reject Error 'catchme'
        .should.be.rejectedWith 'catchme'

    it 'cascaded after a previously catched error', ->
      # Note, there was a bug where the last action was executed but the error
      # was swallowed
      nikita ->
        try
          await @call -> throw Error 'ok'
        catch err
        @call ->
          throw Error 'Catch me'
      .should.be.rejectedWith 'Catch me'
        
    it 'canceled with try/catch', ->
      nikita ->
        @call ->
          try
            await @call ->
              new Promise (resolve, reject) ->
                reject Error 'catchme'
          catch err
            err.message.should.eql 'catchme'
  
    it 'relax with throw error', ->
      nikita ->
        @call ->
          @call ->
            @call ->
              throw Error 'catchme'
            @call ->
              throw Error 'catchme'
            true
        .should.finally.match $status: true

    it 'relax with rejected promise', ->
      nikita ->
        @call ->
          @call ->
            @call ->
              new Promise (resolve, reject) ->
                reject Error 'catchme'
            @call ->
              new Promise (resolve, reject) ->
                reject Error 'catchme'
            true
        .should.finally.match $status: true
  
  describe 'scheduler:args:sequential', ->

    it 'stop on thrown error', ->
      stack = []
      nikita.call [
        ->
          stack.push 1
          true
        ->
          stack.push 2
          throw Error 'catchme'
        ->
          stack.push 3
          true
      ]
      .should.be.rejectedWith 'catchme'
      .then -> stack.should.eql [1,2]

    it 'stop on rejected error', ->
      stack = []
      nikita.call [
        ->
          stack.push 1
          true
        ->
          stack.push 2
          new Promise (resolve, reject) ->
            setTimeout ->
              reject Error 'catchme'
            , 100
        ->
          stack.push 3
          true
      ]
      .should.be.rejectedWith 'catchme'
      .then -> stack.should.eql [1,2]
  
  describe 'scheduler:out', ->

    it 'stop on thrown error', ->
      nikita
      .call -> true
      .call -> throw Error 'catchme'
      .call -> true
      .should.be.rejectedWith 'catchme'
        
