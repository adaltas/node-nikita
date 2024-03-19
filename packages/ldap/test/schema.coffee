
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'ldap.schema', ->
  return unless test.tags.ldap
  
  they.skip 'todo', ({ssh}) ->
    # No test at the moment
    