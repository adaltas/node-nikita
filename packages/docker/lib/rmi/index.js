// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function ({ config }) {
    const {$status} = await this.docker.tools.execute({
      command: [
        "images",
        `| grep '${config.image} '`,
        config.tag != null ? `| grep ' ${config.tag} '` : void 0,
      ].join(" "),
      code: [0, 1],
    });
    await this.docker.tools.execute({
      $if: $status,
      command: [
        "rmi",
        ["force", "no_prune"]
          .filter(function (opt) {
            return config[opt] != null;
          })
          .map((opt) => ` --${opt.replace("_", "-")}`),
        ` ${config.image}`,
        config.tag && `:${config.tag}`,
      ]
        .filter(Boolean)
        .join(""),
    });
  },
  metadata: {
    argument_to_config: "image",
    global: "docker",
    definitions: definitions,
  },
};
