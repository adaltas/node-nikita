// Dependencies
import path from "node:path";
import utils from "@nikitajs/core/utils";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    if (/^\S+@\S+$/.test(config.admin.principal)) {
      if (config.realm == null) {
        config.realm = config.admin.principal.split("@")[1];
      }
    } else {
      if (!config.realm) {
        throw Error('Property "realm" is required unless present in principal');
      }
      config.principal = `${config.principal}@${config.realm}`;
    }
    let keytab = {};
    let princ = {};
    // Get keytab information
    const { $status: entriesExist, stdout: entriesStdout } = await this.execute(
      {
        $shy: true,
        command: `export TZ=GMT; klist -kt ${config.keytab}`,
        code: [0, 1],
      },
    );
    if (entriesExist) {
      log("DEBUG", "Keytab exists, check kvno validity");
      const lines = utils.string.lines(entriesStdout);
      for (const line of lines) {
        const match = /^\s*(\d+)\s+([\d/:]+\s+[\d/:]+)\s+(.*)\s*$/.exec(line);
        if (!match) {
          continue;
        }
        let [, kvno, mdate, principal] = match;
        kvno = parseInt(kvno, 10);
        mdate = Date.parse(`${mdate} GMT`);
        // keytab[principal] ?= {kvno: null, mdate: null}
        if (!keytab[principal] || keytab[principal].kvno < kvno) {
          keytab[principal] = {
            kvno: kvno,
            mdate: mdate,
          };
        }
      }
    }
    // Get principal information
    if (keytab[config.principal] != null) {
      const { $status: princExists, stdout: princStdout } =
        await this.krb5.execute({
          $shy: true,
          admin: config.admin,
          command: `getprinc -terse ${config.principal}`,
        });
      if (princExists) {
        // return do_ktadd() unless -1 is stdout.indexOf 'does not exist'
        let values = utils.string.lines(princStdout)[1];
        if (!values) {
          // Check if a ticket exists for this
          throw Error(`Principal does not exist: '${config.principal}'`);
        }
        values = values.split("\t");
        princ = {
          mdate: parseInt(values[2], 10) * 1000,
          kvno: parseInt(values[8], 10),
        };
        log(
          "INFO",
          `Keytab kvno '${keytab[config.principal].kvno}', principal kvno '${princ.kvno}'`,
        );
        log(
          "INFO",
          `Keytab mdate '${new Date(keytab[config.principal].mdate)}', principal mdate '${new Date(princ.mdate)}'`,
        );
      }
    }
    // Remove principal from keytab
    await this.krb5.execute({
      $if:
        keytab[config.principal] != null &&
        (keytab[config.principal].kvno !== princ.kvno ||
          keytab[config.principal].mdate !== princ.mdate),
      admin: config.admin,
      command: `ktremove -k ${config.keytab} ${config.principal}`,
    });
    // Create keytab and add principal
    await this.fs.mkdir({
      $if:
        keytab[config.principal] == null ||
        keytab[config.principal].kvno !== princ.kvno ||
        keytab[config.principal].mdate !== princ.mdate,
      target: `${path.dirname(config.keytab)}`,
    });
    await this.krb5.execute({
      $if:
        keytab[config.principal] == null ||
        keytab[config.principal].kvno !== princ.kvno ||
        keytab[config.principal].mdate !== princ.mdate,
      admin: config.admin,
      command: `ktadd -k ${config.keytab} ${config.principal}`,
    });
    // Keytab ownership and permissions
    await this.fs.chown({
      $if: config.uid != null || config.gid != null,
      target: config.keytab,
      uid: config.uid,
      gid: config.gid,
    });
    await this.fs.chmod({
      $if: config.mode != null,
      target: config.keytab,
      mode: config.mode,
    });
  },
  metadata: {
    global: "krb5",
    definitions: definitions,
  },
};

// ## Fields in 'getprinc -terse' output

// princ-canonical-name
// princ-exp-time
// last-pw-change
// pw-exp-time
// princ-max-life
// modifying-princ-canonical-name
// princ-mod-date
// princ-attributes <=== This is the field you want
// princ-kvno
// princ-mkvno
// princ-policy (or 'None')
// princ-max-renewable-life
// princ-last-success
// princ-last-failed
// princ-fail-auth-count
// princ-n-key-data
// ver
// kvno
// data-type[0]
// data-type[1]
