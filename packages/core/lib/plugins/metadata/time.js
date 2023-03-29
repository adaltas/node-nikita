/*
# Plugin `@nikitajs/core/lib/plugins/metadata/time`

The time plugin create two metadata properties, `time_start` and `time_end`.
*/

module.exports = {
  name: '@nikitajs/core/lib/plugins/metadata/time',
  hooks: {
    'nikita:action': {
      handler: function(action) {
        action.metadata.time_start = Date.now();
      }
    },
    'nikita:result': {
      before: '@nikitajs/core/lib/plugins/history',
      handler: function({action}) {
        action.metadata.time_end = Date.now();
      }
    }
  }
};
