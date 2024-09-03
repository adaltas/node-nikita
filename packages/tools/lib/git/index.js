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
  handler: async function ({ config, tools: { path } }) {
    // Start real work
    let repo_uptodate = false;
    const { exists: repo_exists } = await this.fs.exists({
      target: config.target,
    });
    if (repo_exists) {
      const { exists: is_git } = await this.fs.exists({
        target: `${config.target}/.git`,
      });
      if (!is_git) {
        throw Error("Not a git repository");
      }
    } else {
      await this.execute({
        command: `git clone ${config.source} ${config.target}`,
        cwd: path.dirname(config.target),
      });
    }
    if (repo_exists) {
      ({ $status: repo_uptodate } = await this.execute({
        $shy: true,
        command: dedent`
          current=\`git log --pretty=format:'%H' -n 1\`
          target=\`git rev-list --max-count=1 ${config.revision}\`
          echo "current revision: $current"
          echo "expected revision: $target"
          if [ $current != $target ]; then exit 3; fi
        `,
        cwd: config.target,
        trap: true,
        code: [0, 3],
      }));
    }
    if (!repo_uptodate) {
      await this.execute({
        command: `git checkout ${config.revision}`,
        cwd: config.target,
      });
    }
  },
  metadata: {
    definitions: definitions,
  },
};
