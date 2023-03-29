
/*
# Plugin `@nikitajs/core/lib/plugins/templated`

The templated plugin transform any string pass as an argument, for example a
metadata or a configuration property, into a template.
*/

const selfTemplated = require('self-templated');

module.exports = {
  name: '@nikitajs/core/lib/plugins/templated',
  hooks: {
    'nikita:action': {
      // Note, conditions plugins define templated as a dependency
      before: ['@nikitajs/core/lib/plugins/metadata/schema'],
      handler: async function(action) {
        const templated = await action.tools.find((action) =>
          action.metadata.templated
        );
        if (templated !== true) {
          return;
        }
        return selfTemplated(action, {
          array: true,
          compile: false,
          mutate: true,
          partial: {
            assertions: true,
            conditions: true,
            config: true,
            metadata: true
          }
        });
      }
    }
  }
};
