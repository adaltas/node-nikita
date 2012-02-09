
assert = require 'assert'
fs = require 'fs'
http = require 'http'
mecano = require '../'
conditions = require '../lib/conditions'

module.exports =
    'conditions # if_exists # no option': (next) ->
        conditions.if_exists(
            {}
            () -> assert.ok false
            () -> next()
        )
    'conditions # if_exists # not exists': (next) ->
        conditions.if_exists(
            if_exists: __dirname
            () -> assert.ok false
            () -> next()
        )
    'conditions # if_exists # exists': (next) ->
        conditions.if_exists(
            if_exists: './oh_no'
            () -> next()
            () -> assert.ok false
        )
    'conditions # not_if_exists # no option': (next) ->
        conditions.not_if_exists(
            {}
            () -> assert.ok false
            () -> next()
        )
    'conditions # not_if_exists # not exists': (next) ->
        conditions.not_if_exists(
            not_if_exists: __dirname
            () -> next()
            () -> assert.ok false
        )
    'conditions # not_if_exists # exists': (next) ->
        conditions.not_if_exists(
            not_if_exists: './oh_no'
            () -> assert.ok false
            () -> next()
        )

