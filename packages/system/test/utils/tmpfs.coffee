
import { parse, stringify } from '@nikitajs/system/utils/tmpfs'
import test from '../test.coffee'

describe 'system.utils.tmpfs', ->
  return unless test.tags.api
  
  it 'parse', ->
    parse '''
      d     /run/user   0755 root root  10d -
      L     /tmp/foobar -    -    -     -   /dev/null
      '''
    .should.eql
      '/run/user':
        type: 'd',
        mount: '/run/user',
        perm: '0755',
        uid: 'root',
        gid: 'root',
        age: '10d',
        argu: undefined
      '/tmp/foobar':
        type: 'L',
        mount: '/tmp/foobar',
        perm: undefined,
        uid: undefined,
        gid: undefined,
        age: undefined,
        argu: '/dev/null'
  
  it 'stringify', ->
    stringify
      '/run/user':
        type: 'd',
        mount: '/run/user',
        perm: '0755',
        uid: 'root',
        gid: 'root',
        age: '10d',
        argu: undefined
      '/tmp/foobar':
        type: 'L',
        mount: '/tmp/foobar',
        perm: undefined,
        uid: undefined,
        gid: undefined,
        age: undefined,
        argu: '/dev/null'
    .should.eql '''
      d /run/user 0755 root root 10d -
      L /tmp/foobar - - - - /dev/null
      '''

    