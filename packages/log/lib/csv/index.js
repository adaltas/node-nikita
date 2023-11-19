// Dependencies
import {merge} from 'mixme';
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: function({config}) {
    const serializer = {
      'nikita:action:start': function({action}) {
        if (!action.metadata.header) {
          return;
        }
        const walk = function(parent) {
          const precious = parent.metadata.header;
          const results = [];
          if (precious !== void 0) {
            results.push(precious);
          }
          if (parent.parent) {
            results.push(...walk(parent.parent));
          }
          return results;
        };
        const headers = walk(action);
        const header = headers.reverse().join(' : ');
        return `header,,${JSON.stringify(header)}\n`;
      },
      'text': function(log) {
        return `${log.type},${log.level},${JSON.stringify(log.message)}\n`;
      }
    };
    config.serializer = merge(serializer, config.serializer);
    return this.log.fs(config);
  },
  metadata: {
    definitions: definitions
  }
};
