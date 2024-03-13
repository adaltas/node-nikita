
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.goodie.prlimit', ->
  return unless test.tags.incus_prlimit

  they 'stdout', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @incus.delete
        container: 'nikita-goodies-prlimit-1'
        force: true
      await @incus.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-goodies-prlimit-1'
        start: true
      await @incus.goodies.prlimit
        container: 'nikita-goodies-prlimit-1'
