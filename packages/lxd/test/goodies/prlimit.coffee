
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'lxc.goodie.prlimit', ->
  return unless test.tags.lxd_prlimit

  they 'stdout', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @lxc.delete
        container: 'nikita-goodies-prlimit-1'
        force: true
      await @lxc.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-goodies-prlimit-1'
        start: true
      await @lxc.goodies.prlimit
        container: 'nikita-goodies-prlimit-1'
