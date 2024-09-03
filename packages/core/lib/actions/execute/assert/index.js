// Dependencies
import utils from "@nikitajs/core/utils";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    const configForExecute = utils.object.filter(config, [
      "code",
      "content",
      "not",
      "trim",
    ]);
    // Command exit code
    const res = await this.execute({
      ...configForExecute,
      $relax: true,
    });
    const code = res.error ? res.error.exit_code : res.code;
    const expectedCodes = utils.array.flatten(
      config.code.true,
      config.code.false,
    );
    if (!config.not) {
      if (!expectedCodes.includes(code)) {
        throw utils.error("NIKITA_EXECUTE_ASSERT_EXIT_CODE", [
          "an unexpected exit code was encountered,",
          `got ${JSON.stringify(code)}`,
          expectedCodes.length === 1 ?
            `while expecting ${expectedCodes}.`
          : `while expecting one of ${JSON.stringify(expectedCodes)}.`,
        ]);
      }
    } else {
      if (expectedCodes.includes(code)) {
        throw utils.error("NIKITA_EXECUTE_ASSERT_NOT_EXIT_CODE", [
          "an unexpected exit code was encountered,",
          `got ${JSON.stringify(code)}`,
          expectedCodes.length === 1 ?
            `while expecting anything but ${expectedCodes}.`
          : `while expecting anything but one of ${JSON.stringify(expectedCodes)}.`,
        ]);
      }
    }
    // Content is a string or a buffer
    for (let content of config.content || []) {
      if (typeof content === "string" && config.trim) {
        content = content.trim();
      }
      if (Buffer.isBuffer(content)) {
        content = content.toString();
      }
      if (typeof content === "string") {
        let { stdout } = await this.execute(configForExecute);
        if (config.trim) {
          stdout = stdout.trim();
        }
        if (!config.not) {
          if (stdout !== content) {
            throw utils.error("NIKITA_EXECUTE_ASSERT_CONTENT", [
              "the command output is not matching the content,",
              `got ${JSON.stringify(stdout)}`,
              `while expecting to match ${JSON.stringify(content)}.`,
            ]);
          }
        } else {
          if (stdout === content) {
            throw utils.error("NIKITA_EXECUTE_ASSERT_NOT_CONTENT", [
              "the command output is unfortunately matching the content,",
              `got ${JSON.stringify(stdout)}.`,
            ]);
          }
        }
      }
      // Content is a regexp
      if (utils.regexp.is(content)) {
        let { stdout } = await this.execute(configForExecute);
        if (config.trim) {
          stdout = stdout.trim();
        }
        if (!config.not) {
          if (!content.test(stdout)) {
            throw utils.error("NIKITA_EXECUTE_ASSERT_CONTENT_REGEX", [
              "the command output is not matching the content regexp,",
              `got ${JSON.stringify(stdout)}`,
              `while expecting to match ${content.toString()}.`,
            ]);
          }
        } else {
          if (content.test(stdout)) {
            throw utils.error("NIKITA_EXECUTE_ASSERT_NOT_CONTENT_REGEX", [
              "the command output is unfortunately matching the content regexp,",
              `got ${JSON.stringify(stdout)}`,
              `matching ${content.toString()}.`,
            ]);
          }
        }
      }
    }
  },
  hooks: {
    on_action: function ({ config }) {
      if (!config.content) {
        return config.code != null ?
            config.code
          : (config.code = { true: [0] });
      }
    },
  },
  metadata: {
    // Schema definitions
    definitions: definitions,
  },
};
