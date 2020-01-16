// Generated by CoffeeScript 2.5.0
// # `nikita.system.user.add`

// Create or modify a Unix user.

// If the user home is provided, its parent directory will be created with root 
// ownerships and 0644 permissions unless it already exists.

// ## Options

// * `arch_chroot` (boolean|string)   
//   Run this command inside a root directory with the arc-chroot command or any
//   provided string, require the "rootdir" option if activated.
// * `rootdir` (string)   
//   Path to the mount point corresponding to the root directory, required if
//   the "arch_chroot" option is activated.
// * `comment`   
//   Short description of the login.
// * `expiredate`   
//   The date on which the user account is disabled.
// * `gid`   
//   Group name or number of the user´s initial login group.
// * `groups`   
//   List of supplementary groups which the user is also a member of.
// * `home`   
//   Value for the user´s login directory, default to the login name appended to "BASE_DIR".
// * `inactive`   
//   The number of days after a password has expired before the account will be
//   disabled.
// * `name`   
//   Login name of the user.
// * `no_home_ownership` (boolean)   
//   Disable ownership on home directory which default to the "uid" and "gid"
//   options, default is "false".
// * `password`   
//   The unencrypted password.
// * `password_sync`   
//   Synchronize password, default is "true".
// * `shell`   
//   Path to the user shell, set to "/sbin/nologin" if "false", "/bin/bash" if
//   true or default to the system shell value in "/etc/default/useradd", by
//   default "/bin/bash".
// * `skel`   
//   The skeleton directory, which contains files and directories to be copied in
//   the user´s home directory, when the home directory is created by useradd.
// * `system`   
//   Create a system account, such user are not created with a home by default,
//   set the "home" option if we it to be created.
// * `uid`   
//   Numerical value of the user´s ID, must not exist.

// ## Callback parameters

// * `err`   
//   Error object if any.
// * `status`   
//   Value is "true" if user was created or modified.

// ## Example

// ```coffee
// require('nikita')
// .system.user({
//   name: 'a_user',
//   system: true,
//   uid: 490,
//   gid: 10,
//   comment: 'A System User'
// }, function(err, {status}){
//   console.log(err ? err.message : 'User created: ' + status);
// })
// ```

// The result of the above action can be viewed with the command
// `cat /etc/passwd | grep myself` producing an output similar to
// "a\_user:x:490:490:A System User:/home/a\_user:/bin/bash". You can also check
// you are a member of the "wheel" group (gid of "10") with the command
// `id a\_user` producing an output similar to 
// "uid=490(hive) gid=10(wheel) groups=10(wheel)".

// ## Source Code
var path, string;

module.exports = function({metadata, options}) {
  var groups_info, ssh, user_info;
  this.log({
    message: "Entering user",
    level: 'DEBUG',
    module: 'nikita/lib/system/user/add'
  });
  // SSH connection
  ssh = this.ssh(options.ssh);
  if (metadata.argument != null) {
    // Options
    options.name = metadata.argument;
  }
  if (!options.name) {
    throw Error("Option 'name' is required");
  }
  if (options.shell === false) {
    options.shell = "/sbin/nologin";
  }
  if (options.shell === true) {
    options.shell = "/bin/bash";
  }
  if (options.system == null) {
    options.system = false;
  }
  if (options.gid == null) {
    options.gid = null;
  }
  if (options.password_sync == null) {
    options.password_sync = true;
  }
  if (typeof options.groups === 'string') {
    options.groups = options.groups.split(',');
  }
  if (typeof options.shell === "function" ? options.shell(typeof options.shell !== 'string') : void 0) {
    throw Error(`Invalid option 'shell': ${JSON.strinfigy(options.shell)}`);
  }
  user_info = groups_info = null;
  this.system.user.read({
    cache: options.cache
  }, function(err, {status, users}) {
    if (err) {
      throw err;
    }
    user_info = users[options.name];
    return this.log(user_info ? {
      message: `Got user information for ${JSON.stringify(options.name)}`,
      level: 'DEBUG',
      module: 'nikita/lib/system/group'
    } : {
      message: `User ${JSON.stringify(options.name)} not present`,
      level: 'DEBUG',
      module: 'nikita/lib/system/group'
    });
  });
  // Get group information if
  // * user already exists
  // * we need to compare groups membership
  this.system.group.read({
    if: function() {
      return user_info && options.groups;
    },
    cache: options.cache
  }, function(err, {status, groups}) {
    groups_info = groups;
    if (groups_info) {
      return this.log({
        message: `Got group information for ${JSON.stringify(options.name)}`,
        level: 'DEBUG',
        module: 'nikita/lib/system/group'
      });
    }
  });
  this.call({
    if: options.home
  }, function() {
    return this.system.mkdir({
      unless_exists: path.dirname(options.home),
      target: path.dirname(options.home),
      uid: 0,
      gid: 0,
      mode: 0o0644 // Same as '/home'
    });
  });
  this.call({
    unless: (function() {
      return user_info;
    })
  }, function() {
    return this.system.execute([
      {
        code_skipped: 9,
        cmd: ['useradd',
      options.system ? '-r' : void 0,
      !options.home ? '-M' : void 0,
      options.home ? '-m' : void 0,
      options.home ? `-d ${options.home}` : void 0,
      options.shell ? `-s ${options.shell}` : void 0,
      options.comment ? `-c ${string.escapeshellarg(options.comment)}` : void 0,
      options.uid ? `-u ${options.uid}` : void 0,
      options.gid ? `-g ${options.gid}` : void 0,
      options.expiredate ? `-e ${options.expiredate}` : void 0,
      options.inactive ? `-f ${options.inactive}` : void 0,
      options.groups ? `-G ${options.groups.join(',')}` : void 0,
      options.skel ? `-k ${options.skel}` : void 0,
      `${options.name}`].join(' ')
      },
      {
        cmd: `chown ${options.name}. ${options.home}`,
        if: options.home
      }
    ], {
      arch_chroot: options.arch_chroot,
      rootdir: options.rootdir,
      sudo: options.sudo
    }, function(err) {
      if (err) {
        throw err;
      }
      return this.log({
        message: "User defined elsewhere than '/etc/passwd', exit code is 9",
        level: 'WARN',
        module: 'nikita/lib/system/user/add'
      });
    });
  });
  this.call({
    if: (function() {
      return user_info;
    })
  }, function() {
    var changed, group, i, j, k, len, len1, ref, ref1;
    changed = [];
    ref = ['uid', 'home', 'shell', 'comment', 'gid'];
    for (i = 0, len = ref.length; i < len; i++) {
      k = ref[i];
      if ((options[k] != null) && user_info[k] !== options[k]) {
        changed.push(k);
      }
    }
    if (options.groups) {
      ref1 = options.groups;
      for (j = 0, len1 = ref1.length; j < len1; j++) {
        group = ref1[j];
        if (!groups_info[group]) {
          throw Error(`Group does not exist: ${group}`);
        }
        if (groups_info[group].users.indexOf(options.name) === -1) {
          changed.push('groups');
        }
      }
    }
    this.log(changed.length ? {
      message: `User ${options.name} modified`,
      level: 'WARN',
      module: 'nikita/lib/system/user/add'
    } : {
      message: `User ${options.name} not modified`,
      level: 'DEBUG',
      module: 'nikita/lib/system/user/add'
    });
    this.system.execute({
      cmd: ['usermod', options.home ? `-d ${options.home}` : void 0, options.shell ? `-s ${options.shell}` : void 0, options.comment != null ? `-c ${string.escapeshellarg(options.comment)}` : void 0, options.gid ? `-g ${options.gid}` : void 0, options.groups ? `-G ${options.groups.join(',')}` : void 0, options.uid ? `-u ${options.uid}` : void 0, `${options.name}`].join(' '),
      if: changed.length,
      arch_chroot: options.arch_chroot,
      rootdir: options.rootdir,
      sudo: options.sudo
    }, function(err) {
      if ((err != null ? err.code : void 0) === 8) {
        throw Error(`User ${options.name} is logged in`);
      }
    });
    return this.system.chown({
      if: options.home && (options.uid || options.gid),
      if_exists: options.home,
      unless: options.no_home_ownership,
      target: options.home,
      uid: options.uid,
      gid: options.gid
    });
  });
  this.call(function() {
    // TODO, detect changes in password
    // echo #{options.password} | passwd --stdin #{options.name}
    return this.system.execute({
      cmd: `hash=$(echo ${options.password} | openssl passwd -1 -stdin)
usermod --pass="$hash" ${options.name}`,
      if: options.password_sync && options.password,
      arch_chroot: options.arch_chroot,
      rootdir: options.rootdir,
      sudo: options.sudo
    }, function(err, {status}) {
      if (err) {
        throw err;
      }
      if (status) {
        return this.log({
          message: "Password modified",
          level: 'WARN',
          module: 'nikita/lib/system/user/add'
        });
      }
    });
  });
  // Reset Cache
  this.call({
    if: function() {
      return this.status();
    }
  }, function() {
    return delete this.store['nikita:etc_passwd'];
  });
  return this.call({
    if: function() {
      return this.status() && options.groups;
    }
  }, function() {
    return delete this.store['nikita:etc_group'];
  });
};

// ## Dependencies
path = require('path');

string = require('../../misc/string');
