// Dependencies
import {merge} from 'mixme';
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({config}) {
    if (config.merge) {
      try {
        const {data} = await this.fs.readFile({
          target: config.target,
          encoding: 'utf8'
        });
        config.content = merge(JSON.parse(data), config.content);
      } catch (error) {
        if (error.code !== 'NIKITA_FS_CRS_TARGET_ENOENT') {
          throw error;
        }
      }
    }
    if (config.source) {
      const {data} = await this.fs.readFile({
        $ssh: config.local ? false : void 0,
        $sudo: config.local ? false : void 0,
        target: config.source,
        encoding: 'utf8'
      });
      config.content = merge(JSON.parse(data), config.content);
    }
    if (config.transform) {
      config.content = config.transform(config.content);
    }
    await this.file({
      target: config.target,
      content: function() {
        return JSON.stringify(config.content, null, config.pretty);
      },
      backup: config.backup,
      diff: config.diff,
      eof: config.eof,
      gid: config.gid,
      uid: config.uid,
      mode: config.mode
    });
    return {};
  },
  hooks: {
    on_action: function({config}) {
      if (config.pretty === true) {
        return config.pretty = 2;
      }
    }
  },
  metadata: {
    definitions: definitions
  }
};
