// Dependencies
import dedent from "dedent";
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
    if (/^\S+@\S+$/.test(config.principal)) {
      if (config.realm == null) {
        config.realm = config.principal.split("@")[1];
      }
    } else {
      if (!config.realm) {
        throw Error('Property "realm" is required in principal');
      }
      config.principal = `${config.principal}@${config.realm}`;
    }
    const entries = [];
    let princ_entries = [];
    let princ = {};
    // Get keytab entries
    const { $status: entriesExist, stdout: entriesStdout } = await this.execute(
      {
        $shy: true,
        command: dedent`
          [ ! -f ${config.keytab} ] && exit 42
          ktutil <<"CMD"
          read_kt ${config.keytab}
          list -e -t
          CMD
        `,
        code: [0, 42, 1],
      },
    );
    if (entriesExist) {
      log("DEBUG", "Principals exist in Keytab, check kvno validity");
      const lines = utils.string.lines(entriesStdout);
      for (const line of lines) {
        const match =
          /^\s*(\d+)\s*(\d+)\s+([\d/:]+\s+[\d/:]+)\s+(.*)\s*\(([\w|-]*)\)\s*$/.exec(
            line,
          );
        if (!match) {
          continue;
        }
        const [, slot, kvno, timestamp, principal, enctype] = match;
        entries.push({
          slot: slot,
          kvno: parseInt(kvno, 10),
          timestamps: timestamp,
          principal: principal.trim(),
          enctype: enctype,
        });
      }
      princ_entries = entries
        .filter((e) => `${e.principal}` === `${config.principal}`)
        .reverse();
    }
    // Get principal information and compare to keytab entries kvnos
    const { $status: principalExists, stdout: principalStdout } =
      await this.krb5.execute({
        $shy: true,
        admin: config.admin,
        command: `getprinc -terse ${config.principal}`,
      });
    if (principalExists) {
      let values = utils.string.lines(principalStdout)[1];
      if (!values) {
        // Check if a ticket exists for this
        throw Error(`Principal does not exist: '${config.principal}'`);
      }
      values = values.split("\t");
      princ = {
        mdate: parseInt(values[2], 10) * 1000,
        kvno: parseInt(values[8], 10),
      };
    }
    // read keytab and check kvno validities
    const removeCommand = config.enctypes
      .map((enctype) => {
        const filteredPrincEntries = princ_entries.filter(
          (entry) => entry.enctype === enctype,
        );
        const entry =
          filteredPrincEntries.length === 1 ?
            entries.filter((entry) => entry.enctype === enctype)[0]
          : null;
        // remove entry if kvno not identical
        if (entry === null || entry?.kvno === princ.kvno) {
          return;
        }
        log(
          "INFO",
          `Remove from Keytab kvno '${entry.kvno}', principal kvno '${princ.kvno}'`,
        );
        return `delete_entry ${entry != null ? entry.slot : void 0}`;
      })
      .filter(Boolean);
    const tmp_keytab = `${config.keytab}.tmp_nikita_${Date.now()}`;
    if (entries.length > princ_entries.length) {
      await this.execute({
        $if: removeCommand.length,
        command: dedent`
          ktutil <<"EOF"
          read_kt ${config.keytab}
          ${removeCommand.join("\n")}
          write_kt ${tmp_keytab}
          EOF
        `,
      });
      await this.fs.move({
        $if: removeCommand.length,
        source: tmp_keytab,
        target: config.keytab,
      });
    }
    if (entries.length === princ_entries.length && removeCommand.length) {
      await this.fs.remove({
        target: config.keytab,
      });
    }
    // write entries in keytab
    const createCommand = config.enctypes
      .map((enctype) => {
        const filteredPrincEntries = princ_entries.filter(
          (entry) => entry.enctype === enctype,
        );
        const entry =
          filteredPrincEntries.length === 1 ?
            entries.filter((entry) => entry.enctype === enctype)[0]
          : null;
        if (entry?.kvno === princ.kvno) {
          return;
        }
        return `add_entry -password -p ${config.principal} -k ${princ.kvno} -e ${enctype}\n${config.password}`;
      })
      .filter(Boolean);
    await this.execute({
      $if: createCommand.length,
      command: dedent`
        ktutil <<"EOF"
        ${createCommand.join("\n")}
        wkt ${config.keytab}
        EOF
      `,
    });
    // Keytab ownership and permissions
    await this.fs.chown({
      $if: config.uid != null || config.gid != null,
      target: config.keytab,
      uid: config.uid,
      gid: config.gid,
    });
    await this.fs.chmod({
      $if: config.mode,
      target: config.keytab,
      mode: config.mode,
    });
  },
  metadata: {
    global: "krb5",
    definitions: definitions,
  },
};
