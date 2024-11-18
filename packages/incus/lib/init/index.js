// Dependencies
import dedent from "dedent";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    const configValue = Object.entries(config.config)
      .map(([key, value]) => `--config ${key}=${value}`)
      .join(` `);
    const commandInit = [
      "incus",
      "init",
      config.image,
      config.name,
      configValue,
      config.network && `--network ${config.network}`,
      config.storage && `--storage ${config.storage}`,
      config.ephemeral && "--ephemeral",
      config.vm && "--vm",
      config.profile && `--profile ${config.profile}`,
      config.target && `--target ${config.target}`,
    ]
      .filter(Boolean)
      .join(" ");
    // Execution
    const { $status } = await this.execute({
      command: dedent`
        incus info ${config.name} >/dev/null && exit 42
        echo '' | ${commandInit}
      `,
      code: [0, 42],
    });
    if (config.vm) {
      // See `agent:config` annoucement in 0.5.1
      // https://discuss.linuxcontainers.org/t/incus-0-5-1-has-been-released/18848
      // await this.execute({
      //   command: dedent`
      //     incus config device add ${esa(config.name)} agent disk source=agent:config
      //   `,
      // });
    }
    await this.incus.start({
      $if: config.start,
      name: config.name,
    });
    return $status;
  },
  metadata: {
    definitions: definitions,
  },
};
