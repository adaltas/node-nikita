// Dependencies
import {merge} from 'mixme';
import definitions from "./schema.json" with { type: "json" };

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
    return this.log.fs({
      archive: config.archive,
      basedir: config.basedir,
      filename: config.filename,
      serializer: merge(serializer, config.serializer),
    });
  },
  metadata: {
    definitions: definitions
  }
};
