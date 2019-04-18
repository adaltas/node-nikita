
nikita = require '@nikitajs/core'
#fs = require 'fs'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'system.dconf', ->
  # Testing the dconf proposed on the github
  they 'changing some dconf settings', ({ssh}) ->
    nikita
      ssh: ssh
    .system.dconf
        key: "/org/gnome/gnome-session/auto-save-session"
        value: "true"
    # Check for another setting 
    .system.dconf
      key: "/com/canonical/indicator/session/show-real-name-on-panel"
      value: "false"
    .promise()
    
  # Testing if the settings were changed using the console      
  they 'checking if the setting were changed', ({ssh}) ->
    nikita
      ssh: ssh
    .system.execute.assert
      cmd: "dconf read /org/gnome/gnome-session/auto-save-session"
      assert: "true"
    .system.execute.assert
      cmd: "dconf read /com/canonical/indicator/session/show-real-name-on-panel"
      assert: "false"
    .promise()
        
