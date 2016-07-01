
mecano = require '../../src'
fs = require 'fs'

describe 'options domain', ->

	it 'uncatchable error in sync handler', (next) ->
		mecano
			domain: true
		.call
			handler: ->
				setImmediate -> 
					throw Error 'Catch me'
		.call ->
			setImmediate ->
				next Error 'Shouldnt be called'
		.then (err, status) ->
			err.message.should.eql 'Invalid State Error [Catch me]'
			next()

  it 'catch thrown error in then', (next) ->
		# @see alternative test in "then.coffee"
    d = domain.create()
    d.on 'error', (err) ->
      err.message.should.eql 'Catchme'
      d.exit()
      next()
    mecano
      domain: d
    .then ->
      throw Error 'Catchme'

  it 'catch thrown error when then not defined', (next) ->
		# @see alternative test in "then.coffee"
    d = domain.create()
    d.on 'error', (err) ->
      err.name.should.eql 'TypeError'
      d.exit()
      next()
    mecano
      domain: d
    .touch
      target: "#{scratch}/a_file"
    .call (options, next) ->
      next.property.does.not.exist
    .call (options) ->
      next Error 'Shouldnt be called'
