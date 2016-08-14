
fs = require 'fs'
path = require 'path'
fs.exists ?= path.exists
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'database user operation', ->

  scratch = test.scratch @
  config = test.config()

  they 'mission options', (ssh, next) ->
    mecano
      ssh: ssh
    .database.user.add
      port: 5432
      engine: 'postgres'
      admin_username: config.database.admin_user
      admin_password: config.database.admin_password
      relax: true
    , (err) ->
      err.message.should.eql 'Missing hostname'
    .database.user.add
      host: 'postgres'
      port: 5432
      engine: 'postgres'
      admin_password: config.database.admin_password
      relax: true
    , (err) ->
      err.message.should.eql 'Missing admin name'
    .then next
  
  they 'add new user (POSTGRES)', (ssh, next) ->
    mecano
      ssh: ssh
    .execute
      cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user}  -c 'DROP USER IF EXISTS test_1;'"
      code_skipped: 1
    .database.user.add
      engine: 'postgres'
      host: 'postgres'
      admin_username: config.database.admin_user
      admin_password: config.database.admin_password
      port: 5432
      name: 'test_1'
      password: 'test_1'
    .execute 
      cmd: "PGPASSWORD=test_1 psql -h postgres -U test_1 -c '\\h' 1>/dev/null"
      code_skipped: 2
    , (err, status, stdout, stderr) ->
      stderr.trim('\n').should.eql 'psql: FATAL:  database "test_1" does not exist'
    .execute
      cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user}  -c 'DROP USER IF EXISTS test_1;'"
      code_skipped: 1
      always: true
    .then next

  they 'add already existing user with new password(POSTGRES)', (ssh, next) ->
    mecano
      ssh: ssh
    .execute
      cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user}  -c 'DROP USER IF EXISTS test_2;'"
      code_skipped: 1
    .database.user.add
      engine: 'postgres'
      host: 'postgres'
      admin_username: config.database.admin_user
      admin_password: config.database.admin_password
      port: 5432
      name: 'test_2'
      password: 'test_1'
    .database.user.add
      engine: 'postgres'
      host: 'postgres'
      admin_username: config.database.admin_user
      admin_password: config.database.admin_password
      port: 5432
      name: 'test_2'
      password: 'test_2'
    .execute 
      cmd: "PGPASSWORD=test_2 psql -h postgres -U test_2 -c '\\h' 1>/dev/null"
      code_skipped: 2
    , (err, status, stdout, stderr) ->
      stderr.trim('\n').should.eql 'psql: FATAL:  database "test_2" does not exist'
    .execute
      cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user}  -c 'DROP USER IF EXISTS test_2;'"
      code_skipped: 1
      always: true
    .then next

  they 'Check if user exists YES (POSTGRES)', (ssh, next) ->
    mecano
      ssh: ssh
    .execute
      cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user}  -c 'DROP USER IF EXISTS test_3;'"
      code_skipped: 1
    .database.user.exists
      engine: 'postgres'
      host: 'postgres'
      admin_username: config.database.admin_user
      admin_password: config.database.admin_password
      port: 5432
      name: 'test_3'
    , (err, status) ->
      status.should.be.false() unless err
    .then next

  they 'Check if user exists FALSE (POSTGRES)', (ssh, next) ->
    mecano
      ssh: ssh
    .execute
      cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user}  -c 'DROP USER IF EXISTS test_4;'"
      code_skipped: 1
    .database.user.add
      engine: 'postgres'
      host: 'postgres'
      admin_username: config.database.admin_user
      admin_password: config.database.admin_password
      port: 5432
      name: 'test_4'
      password: 'test_4'
    .database.user.exists
      engine: 'postgres'
      host: 'postgres'
      admin_username: config.database.admin_user
      admin_password: config.database.admin_password
      port: 5432
      name: 'test_4'
      password: 'test_4'
    , (err, status) ->
      status.should.be.true() unless err
    .then next
