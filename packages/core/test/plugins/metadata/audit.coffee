
import stream from 'node:stream'
# import nikita from '@nikitajs/core'
import session from '@nikitajs/core/session'
# import args from '@nikitajs/core/plugins/args'
import metadataAudit from '@nikitajs/core/plugins/metadata/audit'
import metadataRegister from '@nikitajs/core/plugins/metadata/register'
import metadataSchema from '@nikitajs/core/plugins/metadata/schema'
import metadataRaw from '@nikitajs/core/plugins/metadata/raw'
import metadataTime from '@nikitajs/core/plugins/metadata/time'
import toolsEvents from '@nikitajs/core/plugins/tools/events'
import toolsFind from '@nikitajs/core/plugins/tools/find'
import toolsLog from '@nikitajs/core/plugins/tools/log'
import toolsSchema from '@nikitajs/core/plugins/tools/schema'
import test from '../../test.coffee'

nikita = () ->
  session
    $plugins: [
      # args
      metadataAudit
      metadataRaw
      metadataRegister
      metadataSchema
      metadataTime
      toolsEvents
      toolsFind
      toolsLog
      toolsSchema
    ]
  ,  ({registry}) ->
    registry.register
      'call': '@nikitajs/core/actions/call'
      'registry': 'register': '@nikitajs/core/actions/registry/register'

describe 'metadata "audit"', ->
  return unless test.tags.api
  
  describe 'validation', ->
  
    it 'invalid string', ->
      nikita().call
        $audit: 'invalid'
        $handler: -> throw Error 'ohno'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: /metadata\/audit must be equal to one of the allowed values, allowedValues is \["stdout","stderr"\]/
    
    it.skip 'valid string', ->
      # Testing stdout and stderr print messages to the console
      # unless we temporarily switch process.stdout to a custom implementation
      await nikita().call
        $audit: 'stdout'
        $handler: -> 'ok'
      .should.be.fulfilledWith 'ok'
      await nikita
        $audit: 'stderr'
        $handler: -> 'ok'
      .should.be.fulfilledWith 'ok'
  
    it 'valid stream.Writer', ->
      await nikita()
      .call
        $audit: new stream.Writable( write: (->) )
        $handler: -> 'ok'
      .should.be.fulfilledWith 'ok'
  
    it 'cast to `false`', ->
      # Note, activating schema coercion converted boolean false to a string
      {audit} = await nikita().call
        $audit: false
        $handler: ({metadata}) -> audit: metadata.audit
      audit.should.be.false()

  describe 'type', ->
  
    it 'actions', ->
      data = []
      ws = new stream.Writable()
      ws.write = (chunk) -> data.push chunk
      await nikita().call
        $register:
          'call_0': (->)
          'call_0_0': (->)
          'call_0_0_0': (->)
          'call_1': (->)
          'call_1_0': (->)
          'call_1_1': (->)
          'call_2': (->)
      , ->
        @call $audit: ws, ({tools: {log}}) ->
          await this.call_0 ->
            await this.call_0_0 ->
              await this.call_0_0_0 (->)
          await this.call_1 ->
            await this.call_1_0 (->)
            await this.call_1_1 (->)
          await this.call_2 (->)
      data.map((line) => line.replace(/\d+ms/, 'Xms')).should.eql [
        '[ACTION]       ┌─ call_0_0_0 Xms\n',
        '[ACTION]    ┌─ call_0_0 Xms\n',
        '[ACTION] ┌─ call_0 Xms\n',
        '[ACTION] │  ┌─ call_1_0 Xms\n',
        '[ACTION] │  ├─ call_1_1 Xms\n',
        '[ACTION] ├─ call_1 Xms\n',
        '[ACTION] ├─ call_2 Xms\n',
        '[ACTION] call Xms\n'
      ]
  
    it 'log message in root before any action resolve', ->
      data = []
      ws = new stream.Writable()
      ws.write = (chunk) -> data.push chunk
      await nikita().call
        $register:
          'call_0': (->)
          'call_0_0': (->)
          'call_0_0_0': (->)
          'call_0_0_0_0': (->)
        $audit: ws
      , ({tools: {log}}) ->
        log 'log message 1'
        await this.call_0 ->
          await this.call_0_0 ->
            await this.call_0_0_0 ->
              await this.call_0_0_0_0 (->)
      data.map((line) => line.replace(/\d+ms/, 'Xms')).should.eql [
        '[INFO]   ┌─ log message 1\n',
        '[ACTION] │        ┌─ call_0_0_0_0 Xms\n',
        '[ACTION] │     ┌─ call_0_0_0 Xms\n',
        '[ACTION] │  ┌─ call_0_0 Xms\n',
        '[ACTION] ├─ call_0 Xms\n',
        '[ACTION] call Xms\n'
      ]
  
    it 'log message in leaf before any action resolve', ->
      data = []
      ws = new stream.Writable()
      ws.write = (chunk) -> data.push chunk
      await nikita().call
        $register:
          'call_0': (->)
          'call_0_0': (->)
          'call_0_0_0': (->)
        $audit: ws
      , ->
        await this.call_0 ->
          await this.call_0_0 ->
            await this.call_0_0_0 ({tools: {log}}) ->
              log 'log message 1'
      data.map((line) => line.replace(/\d+ms/, 'Xms')).should.eql [
        '[INFO]            ┌─ log message 1\n'
        '[ACTION]       ┌─ call_0_0_0 Xms\n'
        '[ACTION]    ┌─ call_0_0 Xms\n'
        '[ACTION] ┌─ call_0 Xms\n'
        '[ACTION] call Xms\n'
      ]
  
    it 'log between child actions', ->
      data = []
      ws = new stream.Writable()
      ws.write = (chunk) -> data.push chunk
      await nikita().call
        $register:
          'call_0': (->)
          'call_1': (->)
          'call_1_0': (->)
          'call_1_1': (->)
        $audit: ws
      , ->
        await this.call_0 (->)
        await this.call_1 ({tools: {log}}) ->
          log 'WARN', 'log call_1:start'
          await this.call_1_0 (->)
          await this.call_1_1 (->)
          log 'WARN', 'log call_1:end'
      data.map((line) => line.replace(/\d+ms/, 'Xms')).should.eql [
        '[ACTION] ┌─ call_0 Xms\n'
        '[WARN]   │  ┌─ log call_1:start\n'
        '[ACTION] │  ├─ call_1_0 Xms\n'
        '[ACTION] │  ├─ call_1_1 Xms\n'
        '[WARN]   │  ├─ log call_1:end\n'
        '[ACTION] ├─ call_1 Xms\n'
        '[ACTION] call Xms\n'
      ]
  
    it 'log before root action resolve', ->
      data = []
      ws = new stream.Writable()
      ws.write = (chunk) -> data.push chunk
      await nikita().call
        $register:
          'call_0': (->)
          'call_1': (->)
          'call_1_0': (->)
          'call_1_1': (->)
        $audit: ws
      , ({tools: {log}}) ->
        await this.call_0 (-> 1)
        log 'WARN', 'log call:end'
      data.map((line) => line.replace(/\d+ms/, 'Xms')).should.eql [
        '[ACTION] ┌─ call_0 Xms\n'
        '[WARN]   ├─ log call:end\n'
        '[ACTION] call Xms\n'
      ]
  
  describe 'fix', ->

    it 'handle schema error', ->
      # Used to throw `TypeError: Cannot read properties of undefined (reading 'state')`
      # when the schema is rejected
      ws = new stream.Writable()
      ws.write = (->)
      await session
        $plugins: [
          metadataAudit
          metadataRaw
          metadataSchema
          metadataTime
          toolsEvents
          toolsFind
          toolsLog
          toolsSchema
        ]
        $audit: ws
      , ({registry}) ->
        await registry.register
          'call': '@nikitajs/core/actions/call'
        @call
          $definitions:
            config:
              type: 'object'
              required: ['some_property']
        , (->)
        .should.be.rejectedWith /NIKITA_SCHEMA_VALIDATION_CONFIG/

      