// Dependencies
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    var aliases;
    // config.caname = [config.caname] unless Array.isArray config.caname
    // config.name = [config.name] unless Array.isArray config.name
    aliases = [...config.caname, ...config.name].join(' ').trim();
    if (config.keytool == null) {
      config.keytool = 'keytool';
    }
    return (await this.execute({
      bash: true,
      command: `# Detect keytool command
  keytoolbin=${config.keytool}
  command -v $keytoolbin >/dev/null || {
    if [ -x /usr/java/default/bin/keytool ]; then keytoolbin='/usr/java/default/bin/keytool';
    else exit 7; fi
  }
  test -f "${config.keystore}" || # Nothing to do if not a file
  exit 3
  count=0
  for alias in ${aliases}; do
    if \${keytoolbin} -list -keystore "${config.keystore}" -storepass "${config.storepass}" -alias "$alias"; then
       \${keytoolbin} -delete -keystore "${config.keystore}" -storepass "${config.storepass}" -alias "$alias"
       (( count++ ))
    fi
  done
  [ $count -eq 0 ] && exit 3
  exit 0`,
      code: [0, 3]
    }));
  },
  metadata: {
    definitions: definitions
  }
};
