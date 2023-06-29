
nikita = require '../../lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

describe 'actions.wait', ->
  return unless tags.api

  describe 'time', ->

    it '', ->
      await nikita
      .wait 10
      # .wait (->)
      .wait {a: 1}, (->), {b: 2}

    they 'validate argument', ({ssh}) ->
      before = Date.now()
      nikita
        $ssh: ssh
      .wait
        time: 'an': 'object'
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG: multiple errors were found in the configuration of action `wait`:'
        '#/definitions/config/oneOf config must match exactly one schema in oneOf, passingSchemas is null;'
        '#/definitions/config/oneOf/0/properties/time/type config/time must be integer, type is "integer";'
        '#/definitions/config/oneOf/1/additionalProperties config must NOT have additional properties, additionalProperty is "time".'
      ].join ' '

    they 'as main argument integer', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        {before} = await @call ->
          before: Date.now()
        await @wait 200
        await @wait '200'
        await @wait 0
        interval = Date.now() - before
        (interval >= 400 and interval < 600).should.be.true()

  describe 'handler', ->

    they 'status is `false`', ({ssh}) ->
      nikita
        $ssh: ssh
      .wait () ->
        get: 'me'
      .should.be.finally.match ({
        $status: false,
        get: 'me'
      })

    they 'status is `true`', ({ssh}) ->
      attempt = 0
      nikita
        $ssh: ssh
      .wait () ->
        throw Error 'Its gonna be ok' if attempt++ is 0
        get: 'me'
      .should.be.finally.match ({
        $status: true,
        get: 'me'
      })
