
nikita = require '../../../src'
test = require '../../test'
fs = require 'fs'
path = require 'path'

describe 'api call', ->

  scratch = test.scratch @

  it 'string referencing a sync module', ->
    logs = []
    nikita
    .on 'text', (log) -> logs.push log.message
    .file
      target: "#{scratch}/sync.coffee"
      content: """
      module.exports = ({options}) ->
        @log "Hello \#{options.who or 'world'}"
      """
      log: false
    .call ->
      @call who: 'sync', "#{scratch}/sync"
    .call ->
      logs.should.eql ['Hello sync']
    .promise()

  it 'string referencing an async module', ->
    nikita
    .file
      target: "#{scratch}/async.coffee"
      content: """
      module.exports = ({options}, callback) ->
        callback null, {message: 'hello'}
      """
    .call ->
      @call who: 'async', "#{scratch}/async", (err, {message}) ->
        message.should.eql 'hello' unless err
    .promise()

  it 'string requires a module from process cwd', ->
    cwd = process.cwd()
    process.chdir path.resolve __dirname, "#{scratch}"
    nikita
    .file
      target: "#{scratch}/a_dir/ping.coffee"
      content: 'module.exports = (_, callback) -> callback null, status: true, message: "pong"'
    .call ->
      @call './a_dir/ping', (err, {status, message}) ->
        message.should.eql 'pong' unless err
    .call -> process.chdir cwd
    .promise()

  it 'string requires a module which export an object', ->
    logs = []
    nikita
    .on 'text', (l) -> logs.push l.message
    .call who: 'us', 'test/resources/module_async_object'
    .call ->
      logs[0].should.eql 'Hello us'
    .promise()

  it 'user undefined value should not overwrite default values', ->
    logs = []
    nikita
    .file
      target: "#{scratch}/module.coffee"
      content: """
      module.exports = an_option: false, handler: ({options}, callback) ->
        callback null, an_option: options.an_option
      """
    .call ->
      @call an_option: undefined, "#{scratch}/module", (err, {an_option}) ->
        an_option.should.be.false()
    .promise()
