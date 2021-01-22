
nikita = require '@nikitajs/engine/lib'
{config, images, tags} = require '../test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxd.file.exists', ->

  they 'when present', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @lxd.delete
        container: 'c1'
        force: true
      @lxd.init
        image: "images:#{images.alpine}"
        container: 'c1'
      @lxd.start
        container: 'c1'
      @execute
        command: "lxc exec c1 -- touch /root/a_file"
      {exists} = await @lxd.file.exists
        container: 'c1'
        target: '/root/a_file'
      exists.should.be.true()
  

  they 'when missing', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @lxd.delete
        container: 'c1'
        force: true
      @lxd.init
        image: "images:#{images.alpine}"
        container: 'c1'
      @lxd.start
        container: 'c1'
      {exists} = await @lxd.file.exists
        container: 'c1'
        target: '/root/a_file'
      exists.should.be.false()
  
