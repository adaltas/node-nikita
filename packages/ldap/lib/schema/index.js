// Dependencies
import path from "node:path";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config, metadata: { tmpdir }, tools: { log } }) {
    // TODO: use nikita.ldap.search instead
    // Auth related config
    const binddn = config.binddn ? `-D ${config.binddn}` : "";
    const passwd = config.passwd ? `-w ${config.passwd}` : "";
    if (config.uri === true) {
      config.uri = "ldapi:///";
    }
    const uri = config.uri ? `-H ${config.uri}` : ""; // URI is obtained from local openldap conf unless provided
    if (!config.name) {
      // Schema related config
      throw Error("Missing name");
    }
    if (!config.schema) {
      throw Error("Missing schema");
    }
    config.schema = config.schema.trim();
    const schema = `${tmpdir}/${config.name}.schema`;
    const conf = `${tmpdir}/schema.conf`;
    const ldifTmpDir = path.join(tmpdir, "ldif");
    // ldapsearch -LLL -D cn=admin,cn=config -w config \
    //   -H ldap://openldap:389 \
    //   -b "cn=schema,cn=config" \
    //   "cn={8}samba,cn=schema,cn=config"
    const { $status: exists } = await this.execute({
      command: `ldapsearch -LLL ${binddn} ${passwd} ${uri} -b "cn=schema,cn=config" | grep -E cn=\\{[0-9]+\\}${config.name},cn=schema,cn=config`,
      code: [1, 0],
    });
    if (!exists) {
      return false;
    }
    await this.fs.mkdir({
      target: ldifTmpDir,
    });
    log("DEBUG", "Directory ldif created");
    await this.fs.copy({
      source: config.schema,
      target: schema,
    });
    log("DEBUG", "Schema copied");
    await this.file({
      content: `include ${schema}`,
      target: conf,
    });
    log("DEBUG", "Configuration generated");
    await this.execute({
      command: `slaptest -f ${conf} -F ${ldifTmpDir}`,
    });
    log("DEBUG", "Configuration validated");
    const { $status } = await this.fs.move({
      source: `${ldifTmpDir}/cn=config/cn=schema/cn={0}${config.name}.ldif`,
      target: `${ldifTmpDir}/cn=config/cn=schema/cn=${config.name}.ldif`,
      force: true,
    });
    if (!$status) {
      throw Error("No generated schema");
    }
    log("DEBUG", "Configuration renamed");
    await this.file({
      target: `${ldifTmpDir}/cn=config/cn=schema/cn=${config.name}.ldif`,
      write: [
        {
          match: /^dn: cn.*$/gm,
          replace: `dn: cn=${config.name},cn=schema,cn=config`,
        },
        {
          match: /^cn: {\d+}(.*)$/gm,
          replace: "cn: $1",
        },
        {
          match: /^structuralObjectClass.*/gm,
          replace: "",
        },
        {
          match: /^entryUUID.*/gm,
          replace: "",
        },
        {
          match: /^creatorsName.*/gm,
          replace: "",
        },
        {
          match: /^createTimestamp.*/gm,
          replace: "",
        },
        {
          match: /^entryCSN.*/gm,
          replace: "",
        },
        {
          match: /^modifiersName.*/gm,
          replace: "",
        },
        {
          match: /^modifyTimestamp.*/gm,
          replace: "",
        },
      ],
    });
    log("DEBUG", "File ldif ready");
    await this.execute({
      command: `ldapadd ${uri} ${binddn} ${passwd} -f ${ldifTmpDir}/cn=config/cn=schema/cn=${config.name}.ldif`,
    });
    log("INFO"`Schema added: ${config.name}`);
  },
  metadata: {
    tmpdir: true,
    global: "ldap",
    definitions: definitions,
  },
};
