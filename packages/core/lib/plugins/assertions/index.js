
const session = require('../../session');
const utils = require('../../utils');

const handlers = {
  assert: async function(action, error, output) {
    let final_run = true;
    for (const assertion of action.assertions.assert) {
      let run;
      if (typeof assertion === 'function') {
        run = (await session({
          $: {
            handler: assertion,
            metadata: {
              bastard: true,
              raw_output: true
            },
            parent: action,
            config: action.config,
            error: error,
            output: output
          }
        }));
        if (typeof run !== 'boolean') {
          throw utils.error('NIKITA_ASSERTION_INVALID_OUTPUT', ['invalid assertion output,', 'expect a boolean value,', `got ${JSON.stringify(run)}.`]);
        }
      } else {
        run = utils.object.match(output, assertion);
      }
      if (run === false) {
        final_run = false;
      }
    }
    return final_run;
  },
  unassert: async function(action, error, output) {
    let final_run = true;
    for (const assertion of action.assertions.unassert) {
      let run;
      if (typeof assertion === 'function') {
        run = (await session({
          $: {
            handler: assertion,
            metadata: {
              bastard: true,
              raw_output: true
            },
            parent: action,
            config: action.config,
            error: error,
            output: output
          }
        }));
        if (typeof run !== 'boolean') {
          throw utils.error('NIKITA_ASSERTION_INVALID_OUTPUT', ['invalid assertion output,', 'expect a boolean value,', `got ${JSON.stringify(run)}.`]);
        }
      } else {
        run = utils.object.match(output, assertion);
      }
      if (run === true) {
        final_run = false;
      }
    }
    return final_run;
  }
};

module.exports = {
  name: '@nikitajs/core/lib/plugins/assertions',
  require: [
    '@nikitajs/core/lib/plugins/metadata/raw',
    '@nikitajs/core/lib/plugins/metadata/disabled'
  ],
  hooks: {
    'nikita:normalize': function(action, handler) {
      // Ventilate assertions properties defined at root
      const assertions = {};
      for (const property in action.metadata) {
        let value = action.metadata[property];
        if (/^(un)?assert$/.test(property)) {
          if (assertions[property]) {
            throw Error('ASSERTION_DUPLICATED_DECLARATION', [`Property ${property} is defined multiple times,`, 'at the root of the action and inside assertions']);
          }
          if (!Array.isArray(value)) {
            value = [value];
          }
          assertions[property] = value;
          delete action.metadata[property];
        }
      }
      return async function() {
        action = (await handler.call(null, ...arguments));
        action.assertions = assertions;
        return action;
      };
    },
    'nikita:result': async function({action, error, output}) {
      let final_run = true;
      for (const assertion in action.assertions) {
        if (handlers[assertion] == null) {
          continue;
        }
        const local_run = await handlers[assertion].call(null, action, error, output);
        if (local_run === false) {
          final_run = false;
        }
      }
      if (!final_run) {
        throw utils.error('NIKITA_INVALID_ASSERTION', ['action did not validate the assertion']);
      }
    }
  }
};
