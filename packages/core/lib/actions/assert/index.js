
// Dependencies
import utils from '@nikitajs/core/utils';
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  hooks: {
    on_action: function(action) {
      action.handler = ((handler) =>
        async function({config}) {
          let result = await this.call({
            $raw_output: true,
            $handler: handler
          });
          if (!Array.isArray(result)) {
            result = [result];
          }
          if (!config.strict) {
            result = result.map(function(res) {
              switch (typeof res) {
                case 'undefined':
                  return false;
                case 'boolean':
                  return !!res;
                case 'number':
                  return !!res;
                case 'string':
                  return !!res.length;
                case 'object':
                  if (Buffer.isBuffer(res)) {
                    return !!res.length;
                  } else if (res === null) {
                    return false;
                  } else {
                    return !!Object.keys(res).length;
                  }
                case 'function':
                  throw utils.error('NIKITA_ASSERT_INVALID_OUTPUT', ['assertion does not accept functions']);
              }
            });
          }
          result = !result.some((res) =>
            !config.not ? res !== true : res === true
          );
          if (result !== true) {
            throw utils.error('NIKITA_ASSERT_UNTRUE', ['assertion did not validate,', `got ${JSON.stringify(result)}`]);
          }
        }
      )(action.handler);
    }
  },
  metadata: {
    definitions: definitions
  }
};
