// Generated by CoffeeScript 2.5.0
// # `nikita.system.group`

// Create or modify a Unix group.

// ## Options

// * `cache` (boolean)   
//   Retrieve groups information from cache.
// * `name`   
//   Login name of the group.   
// * `system`   
//   Create a system account, such user are not created with ahome by default,
//   set the "home" option if we it to be created.   
// * `gid`   
//   Group name or number of the user´s initial login group.   

// ## Callback Parameters

// * `err`   
//   Error object if any.   
// * `status`   
//   Value is "true" if group was created or modified.   

// ## Example

// ```js
// require('nikita')
// .system.group({
//   name: 'myself'
//   system: true
//   gid: 490
// }, function(err, status){
//   console.log(err ? err.message : 'Group was created/modified: ' + status);
// });
// ```

// The result of the above action can be viewed with the command
// `cat /etc/group | grep myself` producing an output similar to
// "myself:x:490:".

// ## Source Code
module.exports = function({metadata, options}) {
  var info, ssh;
  this.log({
    message: "Entering group",
    level: 'DEBUG',
    module: 'nikita/lib/system/group'
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
  if (options.system == null) {
    options.system = false;
  }
  if (options.gid == null) {
    options.gid = null;
  }
  if (typeof options.gid === 'string') {
    options.gid = parseInt(options.gid, 10);
  }
  if ((options.gid != null) && isNaN(options.gid)) {
    throw Error('Invalid gid option');
  }
  info = null;
  this.system.group.read({
    cache: options.cache
  }, function(err, {status, groups}) {
    if (err) {
      throw err;
    }
    info = groups[options.name];
    return this.log(info ? {
      message: `Got group information for ${JSON.stringify(options.name)}`,
      level: 'DEBUG',
      module: 'nikita/lib/system/group'
    } : {
      message: `Group ${JSON.stringify(options.name)} not present`,
      level: 'DEBUG',
      module: 'nikita/lib/system/group'
    });
  });
  // Create group
  this.call({
    unless: (function() {
      return info;
    })
  }, function() {
    var cmd;
    return this.system.execute({
      cmd: (cmd = 'groupadd', options.system ? cmd += " -r" : void 0, options.gid != null ? cmd += ` -g ${options.gid}` : void 0, cmd += ` ${options.name}`),
      code_skipped: 9
    }, function(err, {status}) {
      if (err) {
        throw err;
      }
      if (!status) {
        return this.log({
          message: "Group defined elsewhere than '/etc/group', exit code is 9",
          level: 'WARN',
          module: 'nikita/lib/system/group'
        });
      }
    });
  });
  // Modify group
  this.call({
    if: (function() {
      return info;
    })
  }, function() {
    var changed, cmd, i, k, len, ref;
    changed = [];
    ref = ['gid'];
    for (i = 0, len = ref.length; i < len; i++) {
      k = ref[i];
      if ((options[k] != null) && `${info[k]}` !== `${options[k]}`) {
        changed.push('gid');
      }
    }
    this.log(changed.length ? {
      message: "Group information modified",
      level: 'WARN',
      module: 'nikita/lib/system/group'
    } : {
      message: "Group information unchanged",
      level: 'DEBUG',
      module: 'nikita/lib/system/group'
    });
    if (!changed.length) {
      return;
    }
    return this.system.execute({
      if: changed.length,
      cmd: (cmd = 'groupmod', options.gid ? cmd += ` -g ${options.gid}` : void 0, cmd += ` ${options.name}`)
    });
  });
  // Reset Cache
  return this.call({
    if: function() {
      return this.status();
    }
  }, function() {
    return delete this.store['nikita:etc_group'];
  });
};
