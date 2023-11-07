
// Dependencies
const dedent = require('dedent');
const url = require('url');
const utils = require('@nikitajs/file/lib/utils');
const definitions = require("./schema.json");

// Action
module.exports = {
  handler: async function({
    config,
    ssh,
    tools: {log, path}
  }) {
    // Config normalisation
    if (config.source != null) {
      // TODO wdavidw 180115, target should be mandatory and not default to the source filename
      if (config.target == null) {
        config.target = path.resolve("/etc/yum.repos.d", path.basename(config.source));
      }
    }
    config.target = path.resolve('/etc/yum.repos.d', config.target);
    if (config.clean) {
      config.clean = path.resolve(path.dirname(config.target), config.clean);
    }
    // Variable initiation
    let $status = false;
    let remote_files = [];
    // Delete
    if (config.clean) {
      log({
        message: "Searching repositories inside \"/etc/yum.repos.d/\"",
        level: 'DEBUG',
        module: 'nikita/lib/tools/repo'
      });
      const {files} = await this.fs.glob(config.clean);
      remote_files = (function() {
        const results = [];
        for (const file of files) {
          if (file === config.target) {
            continue;
          }
          results.push(file);
        }
        return results;
      })();
    }
    await this.fs.remove(remote_files);
    // Use download unless we are over ssh, in such case,
    // the source default to target host unless local is provided
    const isFile = config.source && url.parse(config.source).protocol === null;
    if (
      config.source != null &&
      (!isFile || (ssh != null && config.local != null))
    ) {
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
    log(`Read GPG keys from ${config.target}`, {
      level: 'DEBUG',
      module: 'nikita/lib/tools/repo'
    });
    // Extract repo information from file
    const data = utils.ini.parse_multi_brackets(
      (
        await this.fs.base.readFile({
          target: config.target,
          encoding: 'utf8'
        })
      ).data
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
      for (const gpgKey of gpgKeys) {
        log(`Downloading GPG keys from ${gpgKey}`, {
          level: 'DEBUG',
          module: 'nikita/lib/tools/repo'
        });
        ({$status} = await this.file.download({
          source: gpgKey,
          target: `${config.gpg_dir}/${path.basename(gpgKey)}`
        }));
        ({$status} = await this.execute({
          $if: $status,
          command: `rpm --import ${config.gpg_dir}/${path.basename(gpgKey)}`
        }));
      }
    }
    // Clean Metadata
    ({$status} = await this.execute({
      $if: path.relative('/etc/yum.repos.d', config.target) !== '..' && $status,
      // wdavidw: 180114, was "yum clean metadata"
      // explanation is provided in case of revert.
      // expire-cache is much faster, it forces yum to go redownload the small
      // repo files only, then if there's newer repo data, it will download it.
      command: 'yum clean expire-cache; yum repolist -y'
    }));
    if (config.update && $status) {
      await this.execute({
        command: dedent`
          yum update -y --disablerepo=* --enablerepo='${repoids.join(',')}'
          yum repolist
        `,
        trap: true
      });
    }
  },
  metadata: {
    definitions: definitions
  }
};
