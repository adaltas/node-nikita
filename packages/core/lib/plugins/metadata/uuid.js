
/*
# Plugin '@nikitajs/core/lib/plugins/metadata/uuid'

Identify each action with a unique identifier.
*/
const {v4: uuid} = require('uuid');

module.exports = {
  name: '@nikitajs/core/lib/plugins/metadata/uuid',
  hooks: {
    'nikita:action': {
      handler: function(action) {
        if (action.metadata.depth === 0) {
          action.metadata.uuid = uuid();
        } else {
          action.metadata.uuid = action.parent.metadata.uuid;
        }
      }
    }
  }
};
