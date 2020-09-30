
nikita = require '@nikitajs/engine/src'
{tags, ssh, scratch} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.tools_dconf

describe 'tools.dconf', ->

  they 'testing some dconf settings', ({ssh}) ->
    nikita
      ssh: ssh
    .tools.dconf
      key: '/org/gnome/desktop/datetime/automatic-timezone'
      value: "true"
    .tools.dconf
      key: '/org/gnome/desktop/peripherals/touchpad/click-method'
      value: "fingers"
    .tools.dconf
      key: '/org/gnome/desktop/input-sources/xkb-options'
      value: '[\'ctrl:swap_lalt_lctl\']'
    .promise()
  
  they 'checking if the settings were changed', ({ssh}) ->
    nikita
      ssh: ssh
    .system.execute.assert
      cmd: "dconf read /org/gnome/desktop/datetime/automatic-timezone"
      assert: "true"
    .system.execute.assert
      cmd: "dconf read /org/gnome/desktop/peripherals/touchpad/click-method"
      assert: "fingers"
    .system.execute.assert
      cmd: 'dconf read /org/gnome/desktop/input-sources/xkb-options'
      assert: '[\'ctrl:swap_lalt_lctl\']'
    .promise()
