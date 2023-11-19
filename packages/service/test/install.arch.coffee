
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'service.install.arch', ->
  
  return unless test.tags.service_install_arch
  
  they 'add pacman options', ({ssh, sudo}) ->
    message = null
    nikita
      $ssh: ssh
      $sudo: sudo
    , ({tools: {events}}) ->
      events.on 'stdin', (log) -> message = log.message
      await @service.remove
        name: test.service.name
      await @service.install
        name: test.service.name
        pacman_flags: ['u', 'y']
      await @call ->
        message.should.containEql "pacman --noconfirm -S #{test.service.name} -u -y"
  
  they 'add yay options', ({ssh, sudo}) ->
    message = null
    nikita
      $ssh: ssh
      $sudo: sudo
    , ({tools: {events}}) ->
      events.on 'stdin', (log) -> message = log.message
      await @service.remove
        name: test.service.name
      await @service.install
        name: test.service.name
        yay_flags: ['u', 'y']
      await @call ->
        message.should.containEql "yay --noconfirm -S #{test.service.name} -u -y"
