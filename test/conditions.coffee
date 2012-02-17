
fs = require 'fs'
http = require 'http'
should = require 'should'
conditions = require '../lib/conditions'

describe 'conditions', ->

    describe 'if', ->

        it 'should bypass if not present', (next) ->
            conditions.if(
                {}
                () -> should.ok false
                next
            )
        it 'should succeed if `true`', (next) ->
            conditions.if(
                if: true
                () -> should.ok false
                next
            )
        it 'should failed if `false`', (next) ->
            conditions.if(
                if: false
                next
                () -> should.ok false
            )
        it 'should succeed on `succeed` callback', (next) ->
            conditions.if(
                if: (options, failed, succeed) -> succeed()
                () -> should.ok false
                next
            )
        it 'should failed on `failed` callback', (next) ->
            conditions.if(
                if: (options, failed, succeed) -> failed()
                next
                () -> should.ok false
            )
        it 'should pass error object on `failed` callback', (next) ->
            conditions.if(
                if: (options, failed, succeed) -> failed new Error 'cool'
                (err) -> err.message is 'cool' and next()
                () -> should.ok false
            )

    describe 'if_exists', ->

        it 'should pass if not present', (next) ->
            conditions.if_exists(
                {}
                () -> should.ok false
                next
            )
        it 'should succeed if dir exists', (next) ->
            conditions.if_exists(
                if_exists: __dirname
                () -> should.ok false
                next
            )
        it 'should failed if file does not exists', (next) ->
            conditions.if_exists(
                if_exists: './oh_no'
                next
                () -> should.ok false
            )
        it 'should succeed if all files exists', (next) ->
            conditions.if_exists(
                if_exists: [__dirname, __filename]
                () -> should.ok false
                next
            )
        it 'should failed if at least one file exists', (next) ->
            conditions.if_exists(
                if_exists: [__dirname, './oh_no']
                next
                () -> should.ok false
            )

    describe 'not_if_exists', ->

        it 'should succeed if not present', (next) ->
            conditions.not_if_exists(
                {}
                () -> should.ok false
                next
            )
        it 'should failed if dir exists', (next) ->
            conditions.not_if_exists(
                not_if_exists: __dirname
                next
                () -> should.ok false
            )
        it 'should succeed if dir does not exists', (next) ->
            conditions.not_if_exists(
                not_if_exists: './oh_no'
                () -> should.ok false
                next
            )
        it 'should succeed if no file exists', (next) ->
            conditions.not_if_exists(
                not_if_exists: ['./oh_no', './eh_no']
                () -> should.ok false
                next
            )
        it 'should failed if at least one file exists', (next) ->
            conditions.not_if_exists(
                not_if_exists: ['./oh_no', __filename]
                next
                () -> should.ok false
            )

