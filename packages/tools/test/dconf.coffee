
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.tools_dconf

describe 'tools.dconf', ->
    
  they 'set single config', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @tools.dconf
        properties:
          '/org/gnome/desktop/datetime/automatic-timezone': false
      {status} = await @tools.dconf
        properties:
          '/org/gnome/desktop/datetime/automatic-timezone': true
      status.should.be.true()
      {status} = await @tools.dconf
        properties:
          '/org/gnome/desktop/datetime/automatic-timezone': true
      status.should.be.false()
      @execute.assert
        command: 'dconf read /org/gnome/desktop/datetime/automatic-timezone'
        assert: 'true'
  
  they 'set multiple configs', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @tools.dconf
        properties:
          '/org/gnome/desktop/datetime/automatic-timezone': false
          '/org/gnome/desktop/peripherals/touchpad/click-method': 1
      {status} = await @tools.dconf
        properties:
          '/org/gnome/desktop/datetime/automatic-timezone': true
          '/org/gnome/desktop/peripherals/touchpad/click-method': 2
      status.should.be.true()
      {status} = await @tools.dconf
        properties:
          '/org/gnome/desktop/datetime/automatic-timezone': true
          '/org/gnome/desktop/peripherals/touchpad/click-method': 2
      status.should.be.false()
      @execute.assert
        command: 'dconf read /org/gnome/desktop/datetime/automatic-timezone'
        assert: 'true'
      @execute.assert
        command: 'dconf read /org/gnome/desktop/peripherals/touchpad/click-method'
        assert: 2
  
