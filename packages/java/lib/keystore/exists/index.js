// Dependencies
import dedent from "dedent";
import utils from "@nikitajs/core/utils";
import { escapeshellarg as esa } from "@nikitajs/utils/string";
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function ({ config }) {
    const { $status } = await this.execute({
      bash: true,
      command: dedent`
        # Detect keytool command
        keytoolbin=\`command -v ${esa(config.keytool)}\` || {
          if [ -x /usr/java/default/bin/keytool ]; then keytoolbin='/usr/java/default/bin/keytool';
          elif [ -x /opt/java/openjdk/bin/keytool ]; then keytoolbin='/opt/java/openjdk/bin/keytool';
          else exit 44; fi
        }
        $keytoolbin -list \
          -keystore ${esa(config.keystore)} \
          -storepass ${esa(config.storepass)} \
          -alias ${esa(config.name)}
      `,
      trap: true,
      code: [0, 1],
    }).catch((error) => {
      if (error.exit_code === 44) {
        throw utils.error("NIKITA_JAVA_KEYTOOL_NOT_FOUND", [
          "Keytool command not detected,",
          `searched ${JSON.stringify(config.keytool)}`,
          ', "/usr/java/default/bin/keytool"',
          ', and "/opt/java/openjdk/bin/keytool."',
        ]);
      }
    });
    return { exists: $status };
  },
  metadata: {
    definitions: definitions,
    metadata: {
      shy: true,
    },
  },
};
