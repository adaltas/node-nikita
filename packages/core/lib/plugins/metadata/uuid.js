
/*
# Plugin '@nikitajs/core/plugins/metadata/uuid'

Identify each action with a unique identifier.
*/

// Dependencies
import {v4 as uuid} from 'uuid';

// Plugin
export default {
  name: '@nikitajs/core/plugins/metadata/uuid',
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
