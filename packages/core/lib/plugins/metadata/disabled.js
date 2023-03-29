
/*
# Plugin `@nikitajs/core/lib/plugins/metadata/disabled`

Desactivate the execution of an action.

Schema validation is not enforced before it because
When a plugin a disabled, chances are that not all its property
where passed correctly and we don't want schema validation
to throw an error in such cases
*/
const dedent = require('dedent')
const {mutate} = require('mixme');

module.exports = {
  name: '@nikitajs/core/lib/plugins/metadata/disabled',
  hooks: {
    'nikita:schema': function({schema}) {
      mutate(schema.definitions.metadata.properties, {
        disabled: {
          type: 'boolean',
          description: dedent`
            Disable the execution of the current action and consequently the
            execution of its child actions.
          `,
          default: false
        }
      });
    },
    'nikita:action': function(action, handler) {
      if (action.metadata.disabled == null) {
        action.metadata.disabled = false;
      }
      if (action.metadata.disabled === true) {
        return null;
      } else {
        return handler;
      }
    }
  }
};
