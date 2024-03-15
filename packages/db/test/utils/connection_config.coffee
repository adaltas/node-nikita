
import { connection_config } from '@nikitajs/db/utils/db'
import test from '../test.coffee'

describe 'db.utils.connection_config', ->
  return unless test.tags.api

  it 'filter properties', ->
    connection_config
      admin_password: 'rootme'
      admin_username: 'root'
      host: 'localhost'
      engine: 'invalid_engine'
      username: 'filtered'
    .should.eql
      admin_password: 'rootme'
      admin_username: 'root'
      host: 'localhost'
      engine: 'invalid_engine'

  