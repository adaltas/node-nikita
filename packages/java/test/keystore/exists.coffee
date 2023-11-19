
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)
__dirname = new URL( '.', import.meta.url).pathname

describe 'java.keystore.exists', ->
  return unless test.tags.java

  they 'with existing alias', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @java.keystore.add
        $shy: true
        keystore: "#{tmpdir}/keystore"
        storepass: "changeit"
        caname: "my_alias"
        cacert: "#{__dirname}/../resources/certs1/cacert.pem"
      await @java.keystore.exists
        keystore: "#{tmpdir}/keystore"
        storepass: "changeit"
        name: "my_alias"
      .then(({exists}) => exists)
      .should.be.finally.equal true

  they 'with missing alias', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @java.keystore.exists
        keystore: "#{tmpdir}/keystore"
        storepass: "changeit"
        name: "my_alias"
      .then(({exists}) => exists)
      .should.be.finally.equal false
