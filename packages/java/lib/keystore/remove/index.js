// Dependencies
import dedent from "dedent";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    const aliases = [...config.caname, ...config.name].join(' ').trim();
    await this.execute({
      bash: true,
      command: dedent`
        # Detect keytool command
        keytoolbin=\`command -v ${config.keytool}\` || {
          if [ -x /usr/java/default/bin/keytool ]; then keytoolbin='/usr/java/default/bin/keytool';
          elif [ -x /opt/java/openjdk/bin/keytool ]; then keytoolbin='/opt/java/openjdk/bin/keytool';
          else exit 43; fi
        }
        # Nothing to do if not a file
        test -f "${config.keystore}" || exit 3
        count=0
        for alias in ${aliases}; do
          if $keytoolbin -list -keystore "${config.keystore}" -storepass "${config.storepass}" -alias "$alias"; then
            $keytoolbin -delete -keystore "${config.keystore}" -storepass "${config.storepass}" -alias "$alias"
            (( count++ ))
          fi
        done
        [ $count -eq 0 ] && exit 3
        exit 0
      `,
      code: [0, 3]
    }).catch((error) => {
      if (error.exit_code === 43) {
        throw utils.error("NIKITA_JAVA_KEYTOOL_NOT_FOUND", [
          "Keytool command not detected,",
          `searched ${JSON.stringify(config.keytool)}`,
          ', "/usr/java/default/bin/keytool"',
          ', and "/opt/java/openjdk/bin/keytool."',
        ]);
      }
    });
  },
  metadata: {
    definitions: definitions
  }
};
