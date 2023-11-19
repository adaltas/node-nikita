

// Dependencies
import utils from '@nikitajs/core/utils';
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    if (Buffer.isBuffer(config.content)) {
      config.content = config.content.toString();
    }
    if (config.content && config.trim) {
      config.content = config.content.trim();
    }
    // Command exit code
    if (config.code != null) {
      const {code} = await this.execute(config, {
        $relax: true
      });
      if (!config.not) {
        if (!config.code.includes(code)) {
          throw utils.error('NIKITA_EXECUTE_ASSERT_EXIT_CODE', ['an unexpected exit code was encountered,', `got ${JSON.stringify(code)}`, config.code.length === 1 ? `while expecting ${config.code}.` : `while expecting one of ${JSON.stringify(config.code)}.`]);
        }
      } else {
        if (config.code.includes(code)) {
          throw utils.error('NIKITA_EXECUTE_ASSERT_NOT_EXIT_CODE', ['an unexpected exit code was encountered,', `got ${JSON.stringify(code)}`, config.code.length === 1 ? `while expecting anything but ${config.code}.` : `while expecting anything but one of ${JSON.stringify(config.code)}.`]);
        }
      }
    }
    // Content is a string or a buffer
    if ((config.content != null) && typeof config.content === 'string') {
      let {stdout} = await this.execute(config);
      if (config.trim) {
        stdout = stdout.trim();
      }
      if (!config.not) {
        if (stdout !== config.content) {
          throw utils.error('NIKITA_EXECUTE_ASSERT_CONTENT', ['the command output is not matching the content,', `got ${JSON.stringify(stdout)}`, `while expecting to match ${JSON.stringify(config.content)}.`]);
        }
      } else {
        if (stdout === config.content) {
          throw utils.error('NIKITA_EXECUTE_ASSERT_NOT_CONTENT', ['the command output is unfortunately matching the content,', `got ${JSON.stringify(stdout)}.`]);
        }
      }
    }
    // Content is a regexp
    if ((config.content != null) && utils.regexp.is(config.content)) {
      let {stdout} = await this.execute(config);
      if (config.trim) {
        stdout = stdout.trim();
      }
      if (!config.not) {
        if (!config.content.test(stdout)) {
          throw utils.error('NIKITA_EXECUTE_ASSERT_CONTENT_REGEX', ['the command output is not matching the content regexp,', `got ${JSON.stringify(stdout)}`, `while expecting to match ${JSON.stringify(config.content)}.`]);
        }
      } else {
        if (config.content.test(stdout)) {
          throw utils.error('NIKITA_EXECUTE_ASSERT_NOT_CONTENT_REGEX', ['the command output is unfortunately matching the content regexp,', `got ${JSON.stringify(stdout)}`, `matching ${JSON.stringify(config.content)}.`]);
        }
      }
    }
  },
  hooks: {
    on_action: function({config, metadata}) {
      if (!config.content) {
        return config.code != null ? config.code : config.code = [0];
      }
    }
  },
  metadata: {
    // Schema definitions
    definitions: definitions
  }
};
