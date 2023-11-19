
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

delete_users = ->
  @ipa.user.del connection: test.ipa,
    uid: 'user_find_1'
  @ipa.user.del connection: test.ipa,
    uid: 'user_find_2'
  @ipa.user.del connection: test.ipa,
    uid: 'user_find_3'
create_users = ->
  @ipa.user connection: test.ipa,
    uid: 'user_find_1'
    attributes:
      givenname: 'Firstname1'
      sn: 'Lastname1'
      mail: [ 'user_find_1@nikita.js.org' ]
  @ipa.user connection: test.ipa,
    uid: 'user_find_2'
    attributes:
      givenname: 'Firstname2'
      sn: 'Lastname2'
      mail: [ 'user_find_2@nikita.js.org' ]
  @ipa.user connection: test.ipa,
    uid: 'user_find_3'
    attributes:
      givenname: 'Firstname3'
      sn: 'Lastname3'
      mail: [ 'user_find_3@nikita.js.org' ]

describe 'ipa.user.find', ->
  return unless test.tags.ipa

  they 'all users', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @call delete_users
      @call create_users
      {result} = await @ipa.user.find connection: test.ipa
      result
      .map (user) -> user.mail?[0]
      .filter (mail) ->
        /^user_find_/.test mail
      .should.eql [
        'user_find_1@nikita.js.org'
        'user_find_2@nikita.js.org'
        'user_find_3@nikita.js.org'
      ]
      @call delete_users

  they 'criteria in_group', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @call delete_users
      @call create_users
      @ipa.group connection: test.ipa,
        cn: 'user_find_group'
      @ipa.group.add_member connection: test.ipa,
        cn: 'user_find_group'
        attributes:
          user: ['user_find_1', 'user_find_3']
      {result} = await @ipa.user.find connection: test.ipa,
        criterias:
          in_group: ['user_find_group']
      result
      .map (user) -> user.mail?[0]
      .filter (user) -> /^user_find_/.test user
      .should.eql [
        'user_find_1@nikita.js.org'
        'user_find_3@nikita.js.org'
      ]
      @call delete_users
