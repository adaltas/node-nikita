
path = require 'path'

module.exports =
  whoami: ({ssh, platform = process.platform} = {}) ->
    return ssh.config.username if ssh
    return process.env['USERPROFILE'].split(path.win32.sep)[2] if /^win/.test platform
    return process.env['USER'] if process.env['USER']
    return process.env['HOME'].split('/')[1] if /^\/root$/.test process.env['HOME']
    return process.env['HOME'].split('/')[2] if /^\/home\/[^\/]+$/.test process.env['HOME']
