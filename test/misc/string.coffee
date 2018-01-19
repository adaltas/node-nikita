
string = require '../../src/misc/string'
test = require '../test'
they = require 'ssh2-they'

describe 'misc string', ->

    it 'escapeshellarg', ->
      string.escapeshellarg("try to 'parse this").should.eql "'try to \\'parse this'"

    it 'hash', ->
      md5 = string.hash "hello"
      md5.should.eql '5d41402abc4b2a76b9719d911017c592'
