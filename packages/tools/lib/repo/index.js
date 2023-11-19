// Dependencies
import each from "each";
import dedent from "dedent";
import url from "node:url";
import utils from "@nikitajs/file/utils";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function ({ config, ssh, tools: { log, path, status } }) {
    // TODO wdavidw 180115, target should be mandatory and not default to the source filename
    if (config.source != null && config.target == null) {
      config.target = path.resolve(
        "/etc/yum.repos.d",
        path.basename(config.source)
      );
    }
    // Unless absolute, path is relative to the default yum repo location
    config.target = path.resolve("/etc/yum.repos.d", config.target);
    // Globing expression relative to the parent target directory
    if (config.clean) {
      config.clean = path.resolve(path.dirname(config.target), config.clean);
    }
    // Delete
    if (config.clean) {
      log("DEBUG", 'Searching repositories inside "/etc/yum.repos.d/"');
      const files = await this.fs
        .glob(config.clean)
        .then(({ files }) => files.filter((file) => file !== config.target));
      await this.fs.remove(files);
    }
    // Use download unless we are over ssh, in such case,
    // the source default to target host unless local is provided
    const isFile = config.source && URL.canParse(config.source) === false;
    if (
      config.source != null &&
      (!isFile || (ssh != null && config.local === true))
    ) {
      // Source is a URL or it is imported from local host if there is an SSH connection
      await this.file.download({
        cache: false,
        gid: config.gid,
        headers: config.headers,
        location: config.location,
        md5: config.md5,
        mode: config.mode,
        proxy: config.proxy,
        source: config.source,
        target: config.target,
        uid: config.uid,
      });
    } else if (config.source != null) {
      await this.fs.copy({
        gid: config.gid,
        mode: config.mode,
        source: config.source,
        target: config.target,
        uid: config.uid,
      });
    } else if (config.content != null) {
      await this.file.types.yum_repo({
        content: config.content,
        gid: config.gid,
        mode: config.mode,
        target: config.target,
        uid: config.uid,
      });
    }
    // Parse the definition file
    log("DEBUG", `Read GPG keys from ${config.target}`);
    // Extract repo information from file
    const data = utils.ini.parse_multi_brackets(
      await this.fs.base
        .readFile({
          target: config.target,
          encoding: "utf8",
        })
        .then(({ data }) => data)
    );
    // Extract repo IDs
    const repoids = Object.keys(data);
    // Extract GPG keys
    const gpgKeys = Object.keys(data)
      .filter((name) => {
        const section = data[name];
        if (section.gpgcheck !== "1") {
          return false;
        }
        if (!(config.gpg_key || section.gpgkey != null)) {
          throw Error("Missing gpgkey");
        }
        if (!/^http(s)??:\/\//.test(section.gpgkey)) {
          return false;
        }
        return true;
      })
      .map((name) => data[name].gpgkey);
    if (config.gpg_key) {
      gpgKeys.push(config.gpg_key);
    }
    // Download GPG Keys
    if (config.verify) {
      const areKeysUpdated = await each(gpgKeys, async (gpgKey) => {
        log("DEBUG", `Downloading GPG key from ${gpgKey}`);
        const { $status: isKeyUpdated } = await this.file.download({
          location: config.location,
          source: gpgKey,
          target: `${config.gpg_dir}/${path.basename(gpgKey)}`,
        });
        await this.execute({
          $if: isKeyUpdated,
          command: `rpm --import ${config.gpg_dir}/${path.basename(gpgKey)}`,
        });
        return isKeyUpdated;
      }).then( statuses => statuses.some( status => status === true));
      // Clean Metadata
      await this.execute({
        $if: path.relative("/etc/yum.repos.d", config.target) !== ".." && areKeysUpdated,
        // wdavidw: 180114, was "yum clean metadata"
        // explanation is provided in case of revert.
        // expire-cache is much faster, it forces yum to go redownload the small
        // repo files only, then if there's newer repo data, it will download it.
        command: "yum clean expire-cache; yum repolist -y",
      });
    }
    if (config.update && status()) {
      await this.execute({
        command: dedent`
          yum update -y --disablerepo=* --enablerepo='${repoids.join(",")}'
          yum repolist
        `,
        trap: true,
      });
    }
  },
  metadata: {
    definitions: definitions,
  },
};
