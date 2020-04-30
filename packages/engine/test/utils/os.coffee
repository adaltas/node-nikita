
{merge} = require 'mixme'
{whoami} = require '../../src/utils/os'

describe 'utils.os', ->

  describe 'whoami', ->
  
    it 'for ssh', ->
      env = merge process.env
      ssh = {config: {username: 'ssh_username'}} # Fake SSH connection
      whoami(ssh: ssh, platform: 'linux').should.eql 'ssh_username'
      process.env = env
      
    it 'for windows', ->
      env = merge process.env
      process.env['USERPROFILE'] = 'C:\\Users\\Zin_user'
      whoami(platform: 'win32').should.eql 'Zin_user'
      process.env = env
      
    it 'for linux root', ->
      env = merge process.env
      delete process.env['USER'] # Found this on Docker environment
      process.env['HOME'] = '/root'
      whoami(platform: 'linux').should.eql 'root'
      process.env = env
      
    it 'for linux user', ->
      env = merge process.env
      delete process.env['USER'] # Found this on Docker environment
      process.env['HOME'] = '/home/linux_username'
      whoami(platform: 'linux').should.eql 'linux_username'
      process.env = env
