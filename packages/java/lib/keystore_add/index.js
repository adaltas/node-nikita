// Dependencies
const dedent = require('dedent');
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function ({
    config,
    ssh,
    metadata: { tmpdir },
    tools: { path },
  }) {
    var err, files;
    // Update paths in case of download
    files = {
      cert:
        ssh && config.local && config.cert != null
          ? `${tmpdir}/${path.local.basename(config.cert)}`
          : config.cert,
      cacert:
        ssh && config.local && config.cacert != null
          ? `${tmpdir}/${path.local.basename(config.cacert)}`
          : config.cacert,
      key:
        ssh && config.local && config.key != null
          ? `${tmpdir}/${path.local.basename(config.key)}`
          : config.key,
    };
    // Temporary directory
    // Used to upload certificates and to isolate certificates from their file
    if (tmpdir) {
      await this.fs.mkdir({
        $shy: true,
        target: tmpdir,
        mode: 0o0700,
      });
    }
    // Upload certificates
    if (ssh && config.local && config.cacert) {
      await this.file.download({
        $shy: true,
        source: config.cacert,
        target: files.cacert,
        mode: 0o0600,
      });
    }
    if (ssh && config.local && config.cert) {
      await this.file.download({
        $shy: true,
        source: config.cert,
        target: files.cert,
        mode: 0o0600,
      });
    }
    if (ssh && config.local && config.key) {
      await this.file.download({
        $shy: true,
        source: config.key,
        target: files.key,
        mode: 0o0600,
      });
    }
    // Prepare parent directory
    await this.fs.mkdir({
      parent: config.parent,
      target: path.dirname(config.keystore),
    });
    try {
      if (!!config.cert) {
        await this.execute({
          bash: true,
          command: `
# Detect openssl command
opensslbin=\`command -v ${config.openssl}\` || {
  echo 'OpenSSL command line tool not detected'; exit 4
}
# Detect keytool command
command -v ${config.keytool} >/dev/null || {
  if [ -x /usr/java/default/bin/keytool ]; then keytoolbin='/usr/java/default/bin/keytool';
  else exit 7; fi
}
keytoolbin=\`command -v ${config.keytool}\`


#opensslbin=/usr/bin/openssl # OK
#opensslbin=/opt/homebrew/bin/openssl # KO

#keytoolbin=/run/current-system/sw/bin/keytool
echo "************ $keytoolbin $opensslbin"
[ -f ${files.cert} ] || (exit 6)
user=\`$opensslbin x509  -noout -in "${files.cert}" -sha1 -fingerprint | sed 's/\\(.*\\)=\\(.*\\)/\\2/'\`
# We are only retrieving the first certificate found in the chain with \`head -n 1\`
keystore=\`$keytoolbin -list -v -keystore ${config.keystore} -storepass ${config.storepass} -alias ${config.name} | grep SHA1: | head -n 1 | sed -E 's/.+SHA1: +(.*)/\\1/'\`
echo "User Certificate: $user"
echo "Keystore Certificate: $keystore"
if [ "$user" = "$keystore" ]; then exit 5; fi
# Create a PKCS12 file that contains key and certificate
$opensslbin pkcs12 -export -in "${files.cert}" -inkey "${files.key}" -out "${tmpdir}/pkcs12" -name ${config.name} -password pass:${config.keypass}
# Import PKCS12 into keystore
$keytoolbin -noprompt -importkeystore -destkeystore ${config.keystore} -deststorepass ${config.storepass} -destkeypass ${config.keypass} -srckeystore "${tmpdir}/pkcs12" -srcstoretype PKCS12 -srcstorepass ${config.keypass} -alias ${config.name}`,
          trap: true,
          code: [
            0,
            5, // OpenSSL exit 3 if file does not exists
          ],
        });
      }
    } catch (error) {
      err = error;
      if (err.exit_code === 4) {
        throw Error("OpenSSL command line tool not detected");
      }
      if (err.exit_code === 6) {
        throw Error("Keystore file does not exists");
      }
      if (err.exit_code === 6) {
        throw Error("Missing Requirement: command keytool is not detected");
      }
      throw err;
    }
    try {
      // Deal with CACert
      if (config.cacert) {
        await this.execute({
          bash: true,
          command: `# Detect keytool command
keytoolbin=${config.keytool}
command -v $keytoolbin >/dev/null || {
  if [ -x /usr/java/default/bin/keytool ]; then keytoolbin='/usr/java/default/bin/keytool';
  else exit 7; fi
}
# Check password
if [ -f ${config.keystore} ] && ! \${keytoolbin} -list -keystore ${config.keystore} -storepass ${config.storepass} >/dev/null; then
  # Keystore password is invalid, change it manually with:
  # keytool -storepasswd -keystore ${config.keystore} -storepass \${old_pasword} -new ${config.storepass}
  exit 2
fi
[ -f ${files.cacert} ] || (echo 'CA file doesnt not exists: ${files.cacert} 1>&2'; exit 3)
# Import CACert
PEM_FILE=${files.cacert}
CERTS=$(grep 'END CERTIFICATE' $PEM_FILE| wc -l)
code=5
for N in $(seq 0 $(($CERTS - 1))); do
  if [ $CERTS -eq '1' ]; then
    ALIAS="${config.caname}"
  else
    ALIAS="${config.caname}-$N"
  fi
  # Isolate cert into a file
  CACERT_FILE=${tmpdir}/$ALIAS
  cat $PEM_FILE | awk "n==$N { print }; /END CERTIFICATE/ { n++ }" > $CACERT_FILE
  # Read user CACert signature
  user=\`${config.openssl} x509  -noout -in "$CACERT_FILE" -sha1 -fingerprint | sed 's/\\(.*\\)=\\(.*\\)/\\2/'\`
  # Read registered CACert signature
  keystore=\`\${keytoolbin} -list -v -keystore ${config.keystore} -storepass ${config.storepass} -alias $ALIAS | grep SHA1: | sed -E 's/.+SHA1: +(.*)/\\1/'\`
  echo "User CA Cert: $user"
  echo "Keystore CA Cert: $keystore"
  if [ "$user" = "$keystore" ]; then echo 'Identical Signature'; code=5; continue; fi
  # Remove CACert if signature doesnt match
  if [ "$keystore" != "" ]; then
    \${keytoolbin} -delete -keystore ${config.keystore} -storepass ${config.storepass} -alias $ALIAS
  fi
  \${keytoolbin} -noprompt -import -trustcacerts -keystore ${config.keystore} -storepass ${config.storepass} -alias $ALIAS -file ${tmpdir}/$ALIAS
  code=0
done
exit $code`,
          trap: true,
          code: [0, 5],
        });
      }
    } catch (error) {
      err = error;
      if (err.exit_code === 3) {
        throw Error(`CA file does not exist: ${files.cacert}`);
      }
      throw err;
    }
    // Ensure ownerships and permissions
    if (config.uid != null || config.gid != null) {
      await this.fs.chown({
        target: config.keystore,
        uid: config.uid,
        gid: config.gid,
      });
    }
    if (config.mode != null) {
      await this.fs.chmod({
        target: config.keystore,
        mode: config.mode,
      });
    }
    return void 0;
  },
  metadata: {
    tmpdir: true,
    definitions: definitions,
  },
};
