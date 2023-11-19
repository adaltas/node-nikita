
// Dependencies
import path from 'node:path'
import dedent from "dedent";
import { escapeshellarg as esa } from "@nikitajs/core/utils/string";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({
    config,
    tools: {log}
  }) {
    log('DEBUG', 'Entering user');
    if (typeof config.shell === "function" ? config.shell(typeof config.shell !== 'string') : void 0) {
      throw Error(`Invalid option 'shell': ${JSON.strinfigy(config.shell)}`);
    }
    const {users} = await this.system.user.read();
    const user_info = users[config.name];
    log(
      "DEBUG",
      user_info
        ? `Got user information for ${JSON.stringify(config.name)}`
        : `User ${JSON.stringify(config.name)} not present`
    );
    // Get group information if
    // * user already exists
    // * we need to compare groups membership
    const {groups: groups_info} = await this.system.group.read({
      $if: user_info && config.groups
    });
    if (groups_info) {
      log('DEBUG', `Got group information for ${JSON.stringify(config.name)}`);
    }
    if (config.home) {
      await this.fs.mkdir({
        $unless_exists: path.dirname(config.home),
        target: path.dirname(config.home),
        uid: 0,
        gid: 0,
        mode: 0o0644 // Same as '/home'
      });
    }
    if (!user_info) {
      await this.execute([
        {
          code: [0, 9],
          command: [
            "useradd",
            config.system && "-r",
            !config.home && "-M",
            config.home && "-m",
            config.home && `-d ${config.home}`,
            config.shell && `-s ${config.shell}`,
            config.comment && `-c ${esa(config.comment)}`,
            config.uid && `-u ${config.uid}`,
            config.gid && `-g ${config.gid}`,
            config.expiredate && `-e ${config.expiredate}`,
            config.inactive && `-f ${config.inactive}`,
            config.groups && `-G ${config.groups.join(",")}`,
            config.skel && `-k ${config.skel}`,
            `${config.name}`,
          ].filter(Boolean).join(" "),
        },
        {
          $if: config.home,
          command: `chown ${config.name}. ${config.home}`,
        },
      ]);
      log("WARN", "User defined elsewhere than '/etc/passwd', exit code is 9");
    } else {
      const changed = [];
      for (const k of ['uid', 'home', 'shell', 'comment', 'gid']) {
        if ((config[k] != null) && user_info[k] !== config[k]) {
          changed.push(k);
        }
      }
      if (config.groups) {
        for (const group of config.groups) {
          if (!groups_info[group]) {
            throw Error(`Group does not exist: ${group}`);
          }
          if (groups_info[group].users.indexOf(config.name) === -1) {
            changed.push('groups');
          }
        }
      }
      log(changed.length ? {
        message: `User ${config.name} modified`,
        level: 'WARN'
      } : {
        message: `User ${config.name} not modified`,
        level: 'DEBUG'
      });
      try {
        await this.execute({
          $if: changed.length,
          command: [
            "usermod",
            config.home && `-d ${config.home}`,
            config.shell && `-s ${config.shell}`,
            config.comment && `-c ${esa(config.comment)}`,
            config.gid && `-g ${config.gid}`,
            config.groups && `-G ${config.groups.join(",")}`,
            config.uid && `-u ${config.uid}`,
            `${config.name}`,
          ].filter(Boolean).join(" "),
        });
      } catch (error) {
        if (error.exit_code === 8) {
          throw Error(`User ${config.name} is logged in`);
        } else {
          throw error;
        }
      }
      if (config.home && (config.uid || config.gid)) {
        await this.fs.chown({
          $if_exists: config.home,
          $unless: config.no_home_ownership,
          target: config.home,
          uid: config.uid,
          gid: config.gid
        });
      }
    }
    // TODO, detect changes in password
    // echo #{config.password} | passwd --stdin #{config.name}
    if (config.password_sync && config.password) {
      const {$status} = await this.execute({
        command: dedent`
          hash=$(echo ${config.password} | openssl passwd -1 -stdin)
          usermod --pass="$hash" ${config.name}
        `
      });
      if ($status) {
        return log('WARN',  "Password modified");
      }
    }
  },
  hooks: {
    on_action: function({config}) {
      switch (config.shell) {
        case true:
          config.shell = '/bin/sh';
          break;
        case false:
          config.shell = '/sbin/nologin';
      }
      if (typeof config.groups === 'string') {
        config.groups = config.groups.split(',');
      }
    }
  },
  metadata: {
    argument_to_config: 'name',
    definitions: definitions
  }
};
