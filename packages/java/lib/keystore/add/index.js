// Dependencies
import dedent from "dedent";
import utils from "@nikitajs/core/utils";
import { escapeshellarg as esa } from "@nikitajs/core/utils/string";
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function ({
    config,
    ssh,
    metadata: { tmpdir },
    tools: { path },
  }) {
    // Update paths in case of download
    const files = {
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
          command: dedent`
            # Detect openssl command
            opensslbin=\`command -v ${config.openssl}\` || {
              echo 'OpenSSL command line tool not detected'; exit 43
            }
            # Detect keytool command
            keytoolbin=\`command -v ${config.keytool}\` || {
              if [ -x /usr/java/default/bin/keytool ]; then keytoolbin='/usr/java/default/bin/keytool';
              elif [ -x /opt/java/openjdk/bin/keytool ]; then keytoolbin='/opt/java/openjdk/bin/keytool';
              else exit 44; fi
            }
            # keytoolbin=\`command -v ${config.keytool}\`
            [ -f ${files.cert} ] || (exit 45)
            user=\`$opensslbin x509  -noout -in "${files.cert}" -sha1 -fingerprint | sed 's/\\(.*\\)=\\(.*\\)/\\2/'\`
            # We are only retrieving the first certificate found in the chain with \`head -n 1\`
            keystore=\`$keytoolbin -list -v -keystore ${config.keystore} -storepass ${config.storepass} -alias ${config.name} | grep SHA1: | head -n 1 | sed -E 's/.+SHA1: +(.*)/\\1/'\`
            echo "User Certificate: $user"
            echo "Keystore Certificate: $keystore"
            if [ "$user" = "$keystore" ]; then exit 5; fi
            # Create a PKCS12 file that contains key and certificate
            $opensslbin pkcs12 -export -in "${files.cert}" -inkey "${files.key}" -out "${tmpdir}/pkcs12" -name ${config.name} -password pass:${config.keypass}
            # Import PKCS12 into keystore
            $keytoolbin -noprompt -importkeystore -destkeystore ${config.keystore} -deststorepass ${config.storepass} -destkeypass ${config.keypass} -srckeystore "${tmpdir}/pkcs12" -srcstoretype PKCS12 -srcstorepass ${config.keypass} -alias ${config.name}
          `,
          trap: true,
          code: [
            0,
            5, // OpenSSL exit 3 if file does not exists
          ],
        });
      }
    } catch (error) {
      if (error.exit_code === 43) {
        throw Error("OpenSSL command line tool not detected.");
      }
      if (error.exit_code === 44) {
        throw utils.error("NIKITA_JAVA_KEYTOOL_NOT_FOUND", [
          "Keytool command not detected,",
          `searched ${JSON.stringify(config.keytool)}`,
          ', "/usr/java/default/bin/keytool"',
          ', and "/opt/java/openjdk/bin/keytool."',
        ]);
      }
      if (error.exit_code === 45) {
        throw utils.error("NIKITA_JAVA_KEYSTORE_NOT_FOUND", [
          "Keystore file does not exists",
          `at location ${JSON.stringify(files.cert)}.`,
        ]);
      }
      throw error;
    }
    try {
      // Deal with CACert
      if (config.cacert) {
        await this.execute({
          bash: true,
          command: dedent`
            # Detect keytool command
            keytoolbin=\`command -v ${config.keytool}\` || {
              if [ -x /usr/java/default/bin/keytool ]; then keytoolbin='/usr/java/default/bin/keytool';
              elif [ -x /opt/java/openjdk/bin/keytool ]; then keytoolbin='/opt/java/openjdk/bin/keytool';
              else exit 43; fi
            }
            # Check password
            if [ -f ${config.keystore} ] && ! $keytoolbin -list -keystore ${config.keystore} -storepass ${config.storepass} >/dev/null; then
              exit 44
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
              keystore=\`$keytoolbin -list -v -keystore ${config.keystore} -storepass ${config.storepass} -alias $ALIAS | grep SHA1: | sed -E 's/.+SHA1: +(.*)/\\1/'\`
              echo "User CA Cert: $user"
              echo "Keystore CA Cert: $keystore"
              if [ "$user" = "$keystore" ]; then echo 'Identical Signature'; code=5; continue; fi
              # Remove CACert if signature doesnt match
              if [ "$keystore" != "" ]; then
                $keytoolbin -delete -keystore ${config.keystore} -storepass ${config.storepass} -alias $ALIAS
              fi
              $keytoolbin -noprompt -import -trustcacerts -keystore ${config.keystore} -storepass ${config.storepass} -alias $ALIAS -file ${tmpdir}/$ALIAS
              code=0
            done
            exit $code
          `,
          trap: true,
          code: [0, 5],
        });
      }
    } catch (error) {
      if (error.exit_code === 43) {
        throw utils.error("NIKITA_JAVA_KEYTOOL_NOT_FOUND", [
          "Keytool command not detected,",
          `searched ${JSON.stringify(config.keytool)}`,
          ', "/usr/java/default/bin/keytool"',
          ', and "/opt/java/openjdk/bin/keytool."',
        ]);
      }
      if (error.exit_code === 44) {
        throw utils.error("NIKITA_JAVA_KEYSTORE_INVALID_PASSWORD", [
          "Keystore password is invalid,",
          "change it manually with:",
          `\`keytool -storepasswd -keystore ${esa(
            config.keystore
          )} -storepass <old_pasword> -new <new_password>'\``,
        ]);
      }
      if (error.exit_code === 3) {
        throw Error(`CA file does not exist: ${files.cacert}`);
      }
      throw error;
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
