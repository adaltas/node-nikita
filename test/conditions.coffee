
assert = require 'assert'
fs = require 'fs'
http = require 'http'
mecano = require '../'
conditions = require '../lib/conditions'

module.exports =
    'conditions # if # undefined': (next) ->
        conditions.if(
            {}
            () -> assert.ok false
            next
        )
    'conditions # if # boolean true': (next) ->
        conditions.if(
            if: true
            () -> assert.ok false
            next
        )
    'conditions # if # boolean false': (next) ->
        conditions.if(
            if: false
            next
            () -> assert.ok false
        )
    'conditions # if # function true': (next) ->
        conditions.if(
            if: (options, failed, succeed) -> succeed()
            () -> assert.ok false
            next
        )
    'conditions # if # function false': (next) ->
        conditions.if(
            if: (options, failed, succeed) -> failed()
            next
            () -> assert.ok false
        )
    'conditions # if # function err': (next) ->
        conditions.if(
            if: (options, failed, succeed) -> failed new Error 'cool'
            (err) -> err.message is 'cool' and next()
            () -> assert.ok false
        )
    'conditions # if_exists # undefined': (next) ->
        conditions.if_exists(
            {}
            () -> assert.ok false
            next
        )
    'conditions # if_exists # not exists': (next) ->
        conditions.if_exists(
            if_exists: __dirname
            () -> assert.ok false
            next
        )
    'conditions # if_exists # exists': (next) ->
        conditions.if_exists(
            if_exists: './oh_no'
            next
            () -> assert.ok false
        )
    'conditions # if_exists # partial exists': (next) ->
        conditions.if_exists(
            if_exists: [__dirname, __filename]
            () -> assert.ok false
            next
        )
    'conditions # if_exists # partial not exists': (next) ->
        conditions.if_exists(
            if_exists: [__dirname, './oh_no']
            next
            () -> assert.ok false
        )
    'conditions # not_if_exists # undefined': (next) ->
        conditions.not_if_exists(
            {}
            () -> assert.ok false
            next
        )
    'conditions # not_if_exists # not exists': (next) ->
        conditions.not_if_exists(
            not_if_exists: __dirname
            next
            () -> assert.ok false
        )
    'conditions # not_if_exists # exists': (next) ->
        conditions.not_if_exists(
            not_if_exists: './oh_no'
            () -> assert.ok false
            next
        )
    'conditions # not_if_exists # partial exists': (next) ->
        conditions.not_if_exists(
            not_if_exists: ['./oh_no', './eh_no']
            () -> assert.ok false
            next
        )
    'conditions # not_if_exists # partial exists': (next) ->
        conditions.not_if_exists(
            not_if_exists: ['./oh_no', __filename]
            next
            () -> assert.ok false
        )

