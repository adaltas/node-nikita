
import { command } from '@nikitajs/db/utils/db'
import test from '../test.coffee'

describe 'db.utils.command', ->
  return unless test.tags.api

  it 'invalid engine', ->
    () -> command
      admin_password: 'rootme'
      admin_username: 'root'
      host: 'localhost'
      engine: 'invalid_engine'
    .should.throw 'Unsupported engine: "invalid_engine"'
  
  it 'required arguments', ->
      () -> command
        admin_password: 'rootme'
        host: 'local'
        engine: 'mariadb'
      .should.throw
        code: 'NIKITA_DB_UTILS_REQUIRED_ARGUMENTS'
        message: [
          'NIKITA_DB_UTILS_REQUIRED_ARGUMENTS:'
          'Missing required argument: "admin_username"'
        ].join ' '
      () -> command
        admin_username: 'root'
        host: 'local'
        engine: 'mariadb'
      .should.throw
        code: 'NIKITA_DB_UTILS_REQUIRED_ARGUMENTS'
        message: [
          'NIKITA_DB_UTILS_REQUIRED_ARGUMENTS:'
          'Missing required argument: "admin_password"'
        ].join ' '
      () -> command
        admin_password: 'rootme'
        admin_username: 'root'
        engine: 'mariadb'
      .should.throw
        code: 'NIKITA_DB_UTILS_REQUIRED_ARGUMENTS'
        message: [
          'NIKITA_DB_UTILS_REQUIRED_ARGUMENTS:'
          'Missing required argument: "host"'
        ].join ' '
      () -> command
        admin_password: 'rootme'
        engine: 'mariadb'
      .should.throw
        code: 'NIKITA_DB_UTILS_REQUIRED_ARGUMENTS'
        message: new RegExp 'Missing required argument:'
    
  describe 'using engine: mariadb', ->
    
    it 'default values', ->
      command
        admin_password: 'rootme'
        admin_username: 'root'
        engine: 'mariadb'
        host: 'localhost'
      .should.equal 'mysql -hlocalhost -P3306 -uroot -p\'rootme\''
    
    it 'user values', ->
      command
        admin_password: 'password'
        admin_username: 'test_user'
        engine: 'mariadb'
        host: 'mariadb'
        port: 1729
      .should.equal 'mysql -hmariadb -P1729 -utest_user -p\'password\''
  
    it 'command option', ->
      command
        admin_password: 'password'
        admin_username: 'test_user'
        engine: 'mariadb'
        host: 'mariadb'
        port: 1729
        command: '''
        show databases;
        '''
      .should.equal 'mysql -hmariadb -P1729 -utest_user -p\'password\' -e "show databases;"'
      
  describe 'using engine: postgresql', ->
    
    it 'default values', ->
      command
        admin_password: 'rootme'
        admin_username: 'root'
        engine: 'postgresql'
        host: 'localhost'
      .should.equal 'PGPASSWORD=rootme psql -h localhost -p 5432 -U root -tAq'
    
    it 'user values', ->
      command
        admin_password: 'password'
        admin_username: 'test_user'
        engine: 'postgresql'
        host: 'postgresql'
        port: 1729
      .should.equal 'PGPASSWORD=password psql -h postgresql -p 1729 -U test_user -tAq'
    
    it 'command option', ->
      command
        admin_password: 'password'
        admin_username: 'test_user'
        engine: 'postgresql'
        host: 'postgresql'
        port: 1729
        command: '''
        show databases;
        '''
      .should.equal 'PGPASSWORD=password psql -h postgresql -p 1729 -U test_user -tAq -c "show databases;"'
