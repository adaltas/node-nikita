
nikita = require '@nikitajs/core/lib'
{tags, config, images} = require './test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.query', ->

  describe 'base options', ->

    they 'with path', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        {$status, data} = await @lxc.query
          path: '/1.0'
        $status.should.eql true
        data.api_version.should.eql '1.0'
    
    they 'with wait option', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        {$status, data} = await @lxc.query
          path: '/1.0'
          wait: true
        $status.should.eql true
        data.api_version.should.eql '1.0'

    they 'with get request option', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        {$status, data} = await @lxc.query
          path: '/1.0'
          request: 'GET'
        $status.should.eql true
        data.api_version.should.eql '1.0'
  
  describe 'format', ->
  
    they 'format json', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        {$status, data} = await @lxc.query
          path: '/1.0'
          request: 'GET'
          format: 'json'
        $status.should.eql true
        (typeof data).should.be.eql "object" 
    
    they 'format string', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        {$status, data} = await @lxc.query
          path: '/1.0'
          request: 'GET'
          format: 'string'
        $status.should.eql true
        (typeof data).should.be.eql "string"

  describe 'requests', ->

    they 'stop a container with PUT request', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          @lxc.delete 'nikita-query-1', force: true
        await @clean()
        await @lxc.init
          image: "images:#{images.alpine}"
          container: 'nikita-query-1'
          start: true
        {$status, data} = await @lxc.query
          path: '/1.0/instances/nikita-query-1/state'
          request: 'PUT'
          data: '{"action": "stop", "force": true}'
          wait: true
        $status.should.eql true
        {$status} = await @lxc.running
          container: 'nikita-query-1'
        $status.should.eql false
        await @clean()
  
  describe 'errors', ->

    they 'call a non-existing path', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        {$status, data} = await @lxc.query
          path: '/1.0/unknown'
          code: [0, 1]
        $status.should.eql false
        data.should.eql {}
    
    they 'call a non-existing path with string', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        {$status, data} = await @lxc.query
          path: '/1.0/unknown'
          format: 'string'
          code: [0, 1]
        $status.should.eql false
        data.should.eql ""
    
    
    they "didn't add a path", ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        {$status, data} = await @lxc.query
          request: 'GET'
        .should.be.rejectedWith /^NIKITA_SCHEMA_VALIDATION_CONFIG:/
