
import stream from 'node:stream'
import nikita from '@nikitajs/core'
import test from '../../test.coffee'

describe 'metadata "audit"', ->
  return unless test.tags.api
  
  describe 'validation', ->
  
    it 'invalid string', ->
      nikita
        $audit: 'invalid'
        $handler: -> throw Error 'ohno'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: /metadata\/audit must be equal to one of the allowed values, allowedValues is \["stdout","stderr"\]/
    
    it.skip 'valid string', ->
      # Testing stdout and stderr print messages to the console
      # unless we temporarily switch process.stdout to a custom implementation
      await nikita
        $audit: 'stdout'
        $handler: -> 'ok'
      .should.be.fulfilledWith 'ok'
      await nikita
        $audit: 'stderr'
        $handler: -> 'ok'
      .should.be.fulfilledWith 'ok'
  
    it 'valid stream.Writer', ->
      await nikita
        $audit: new stream.Writable( write: (->) )
        $handler: -> 'ok'
      .should.be.fulfilledWith 'ok'
  
    it 'cast to `false`', ->
      # Note, activating schema coercion converted boolean false to a string
      {audit} = await nikita
        $audit: false
        $handler: ({metadata}) -> audit: metadata.audit
      audit.should.be.false()

  describe 'type', ->
  
    it 'actions', ->
      data = []
      ws = new stream.Writable()
      ws.write = (chunk) -> data.push chunk
      await nikita
      .registry.register 'call_0', (->)
      .registry.register 'call_0_0', (->)
      .registry.register 'call_0_0_0', (->)
      .registry.register 'call_1', (->)
      .registry.register 'call_1_0', (->)
      .registry.register 'call_1_1', (->)
      .registry.register 'call_2', (->)
      .call ->
        @call $audit: ws, ({tools: {log}}) ->
          await this.call_0 ->
            await this.call_0_0 ->
              await this.call_0_0_0 (->)
          await this.call_1 ->
            await this.call_1_0 (->)
            await this.call_1_1 (->)
          await this.call_2 (->)
      data.map((line) => line.replace(/\d+ms/, 'Xms')).should.eql [
        '[AUDIT]       ┌─ call_0_0_0 Xms\n',
        '[AUDIT]    ┌─ call_0_0 Xms\n',
        '[AUDIT] ┌─ call_0 Xms\n',
        '[AUDIT] │  ┌─ call_1_0 Xms\n',
        '[AUDIT] │  ├─ call_1_1 Xms\n',
        '[AUDIT] ├─ call_1 Xms\n',
        '[AUDIT] ├─ call_2 Xms\n',
        '[AUDIT] call Xms\n'
      ]
  
    it 'log message in root before any action resolve', ->
      data = []
      ws = new stream.Writable()
      ws.write = (chunk) -> data.push chunk
      await nikita
      .registry.register 'call_0', (->)
      .registry.register 'call_0_0', (->)
      .registry.register 'call_0_0_0', (->)
      .registry.register 'call_0_0_0_0', (->)
      .call $audit: ws, ({tools: {log}}) ->
        log 'log message 1'
        await this.call_0 ->
          await this.call_0_0 ->
            await this.call_0_0_0 ->
              await this.call_0_0_0_0 (->)
      data.map((line) => line.replace(/\d+ms/, 'Xms')).should.eql [
        '[INFO]  ┌─ log message 1\n',
        '[AUDIT] │        ┌─ call_0_0_0_0 Xms\n',
        '[AUDIT] │     ┌─ call_0_0_0 Xms\n',
        '[AUDIT] │  ┌─ call_0_0 Xms\n',
        '[AUDIT] ├─ call_0 Xms\n',
        '[AUDIT] call Xms\n'
      ]
  
    it 'log message in leaf before any action resolve', ->
      data = []
      ws = new stream.Writable()
      ws.write = (chunk) -> data.push chunk
      await nikita
      .registry.register 'call_0', (->)
      .registry.register 'call_0_0', (->)
      .registry.register 'call_0_0_0', (->)
      .call $audit: ws, ->
        await this.call_0 ->
          await this.call_0_0 ->
            await this.call_0_0_0 ({tools: {log}}) ->
              log 'log message 1'
      data.map((line) => line.replace(/\d+ms/, 'Xms')).should.eql [
        '[INFO]           ┌─ log message 1\n'
        '[AUDIT]       ┌─ call_0_0_0 Xms\n'
        '[AUDIT]    ┌─ call_0_0 Xms\n'
        '[AUDIT] ┌─ call_0 Xms\n'
        '[AUDIT] call Xms\n'
      ]
  
    it 'log between child actions', ->
      data = []
      ws = new stream.Writable()
      ws.write = (chunk) -> data.push chunk
      await nikita
      .registry.register 'call_0', (->)
      .registry.register 'call_1', (->)
      .registry.register 'call_1_0', (->)
      .registry.register 'call_1_1', (->)
      .call $audit: ws, ->
        await this.call_0 (->)
        await this.call_1 ({tools: {log}}) ->
          log 'WARN', 'log call_1:start'
          await this.call_1_0 (->)
          await this.call_1_1 (->)
          log 'WARN', 'log call_1:end'
      data.map((line) => line.replace(/\d+ms/, 'Xms')).should.eql [
        '[AUDIT] ┌─ call_0 Xms\n'
        '[WARN]  │  ┌─ log call_1:start\n'
        '[AUDIT] │  ├─ call_1_0 Xms\n'
        '[AUDIT] │  ├─ call_1_1 Xms\n'
        '[WARN]  │  ├─ log call_1:end\n'
        '[AUDIT] ├─ call_1 Xms\n'
        '[AUDIT] call Xms\n'
      ]
  
    it 'log before root action resolve', ->
      data = []
      ws = new stream.Writable()
      ws.write = (chunk) -> data.push chunk
      await nikita
      .registry.register 'call_0', (->)
      .registry.register 'call_1', (->)
      .registry.register 'call_1_0', (->)
      .registry.register 'call_1_1', (->)
      .call $audit: ws, ({tools: {log}}) ->
        await this.call_0 (->)
        log 'WARN', 'log call:end'
      data.map((line) => line.replace(/\d+ms/, 'Xms')).should.eql [
        '[AUDIT] ┌─ call_0 Xms\n'
        '[WARN]  ├─ log call:end\n'
        '[AUDIT] call Xms\n'
      ]
      