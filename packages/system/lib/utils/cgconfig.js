import string from '@nikitajs/core/utils/string';

export default {
  parse: function(str) {
    let list_of_mount_sections = [];
    let list_of_group_sections = {};
    // variable which hold the cursor position
    let current_mount = false;
    let current_group = false;
    let current_group_name = '';
    let current_group_controller = false;
    let current_group_perm = false;
    let current_group_perm_content = false;
    let current_default = false;
    // variables which hold the data
    let current_mount_section = null;
    let current_group_section = null; // group section is a tree but only of group
    let current_controller_name = null;
    let current_group_section_perm_name = null;
    string.lines(str).forEach(function(line, _, __) {
      if (!line || line.match(/^\s*$/)) {
        return;
      }
      if (!current_mount && !current_group && !current_default) {
        if (/^mount\s{$/.test(line)) { // start of a mount object
          current_mount = true;
          current_mount_section = [];
        }
        if (/^(group)\s([A-z|0-9|\/]*)\s{$/.test(line)) { // start of a group object
          current_group = true;
          const match = /^(group)\s([A-z|0-9|\/]*)\s{$/.exec(line);
          current_group_name = match[2];
          current_group_section = {};
          if (list_of_group_sections[current_group_name] == null) {
            list_of_group_sections[current_group_name] = {};
          }
        }
        if (/^(default)\s{$/.test(line)) { // start of a special group object named default
          current_group = true;
          current_group_name = '';
          current_group_section = {};
          list_of_group_sections[current_group_name] ??= {};
        }
      } else {
        // we are parsing a mount object
        // ^(cpuset|cpu|cpuacct|memory|devices|freezer|net_cls|blkio)\s=\s[aA-zZ|\s]*
        if (current_mount) {
          if (/^}$/.test(line)) { // close the mount object
            list_of_mount_sections.push(...current_mount_section);
            current_mount = false;
            current_mount_section = [];
          } else {
            // add the line to mont object
            line = line.replace(';', '');
            const sep = line.indexOf(':') !== -1 ? ':' : '=';
            line = line.split(sep);
            current_mount_section.push({
              type: `${line[0].trim()}`,
              path: `${line[1].trim()}`
            });
          }
        }
        // we are parsing a group object
        // ^(cpuset|cpu|cpuacct|memory|devices|freezer|net_cls|blkio)\s=\s[aA-zZ|\s]*
        if (current_group) {
          // if a closing bracket is encountered, it should set the cursor to false
          if (/^(\s*)?}$/.test(line)) {
            if (current_group) {
              if (current_group_controller) {
                current_group_controller = false;
              } else if (current_group_perm) {
                if (current_group_perm_content) {
                  current_group_perm_content = false;
                } else {
                  current_group_perm = false;
                }
              } else {
                current_group = false;
                // push the group if the closing bracket is closing a group
                // list_of_group_sections["#{current_group_name}"] = current_group_section
                current_group_section = null;
              }
            }
          } else {
            //closing the group object
            const match = /^\s*(cpuset|cpu|cpuacct|blkio|memory|devices|freezer|net_cls|perf_event|net_prio|hugetlb|pids|rdma)\s{$/.exec(line);
            if (!current_group_perm && !current_group_controller) {
              //if neither working in perm or controller section, we are declaring one of them
              if (/^\s*perm\s{$/.test(line)) { // perm declaration
                current_group_perm = true;
                current_group_section['perm'] = {};
                list_of_group_sections[`${current_group_name}`]['perm'] = {};
              }
              if (match) { //controller declaration
                current_group_controller = true;
                current_controller_name = match[1];
                current_group_section[`${current_controller_name}`] = {};
                list_of_group_sections[`${current_group_name}`][current_controller_name] ??= {};
              }
            } else if (current_group_perm && current_group_perm_content) { // perm config
              line = line.replace(';', '');
              line = line.split('=');
              const [type, value] = line;
              current_group_section['perm'][current_group_section_perm_name][type.trim()] = value.trim();
              list_of_group_sections[`${current_group_name}`]['perm'][current_group_section_perm_name][type.trim()] = value.trim();
            } else if (current_group_controller) { // controller config
              line = line.replace(';', '');
              const sep = line.indexOf(':') !== -1 ? ':' : '=';
              const [type, value] = line.split(sep);
              list_of_group_sections[`${current_group_name}`][`${current_controller_name}`][type.trim()] ??= value.trim()
            } else {
              const match_admin = /^\s*(admin|task)\s{$/.exec(line);
              if (match_admin) { // admin or task declaration
                const [_, name] = match_admin; //the name is either admin or task
                current_group_perm_content = true;
                current_group_section_perm_name = name;
                current_group_section['perm'][name] = {};
                list_of_group_sections[`${current_group_name}`]['perm'][name] = {};
              }
            }
          }
        }
      }
    });
    return {
      mounts: list_of_mount_sections,
      groups: list_of_group_sections
    };
  },
  stringify: function(obj, config = {}) {
    if (obj.mounts == null) {
      obj.mounts = [];
    }
    if (obj.groups == null) {
      obj.groups = {};
    }
    if (config.indent == null) {
      config.indent = 2;
    }
    let indent = ' '.repeat(config.indent);
    const sections = [];
    if (obj.mounts.length !== 0) {
      let mount_render = "mount {\n";
      for (const mount of obj.mounts) {
        mount_render += `${indent}${mount.type} = ${mount.path};\n`;
      }
      mount_render += '}';
      sections.push(mount_render);
    }
    let count = 0;
    for (const name in obj.groups) {
      const group = obj.groups[name];
      let group_render = (name === '') || (name === 'default') ? 'default {\n' : `group ${name} {\n`;
      for (const key in group) {
        const value = group[key];
        if (key === 'perm') {
          group_render += `${indent}perm {\n`;
          if (value['admin'] != null) {
            group_render += `${indent}${indent}admin {\n`;
            for (const prop in value['admin']) {
              const val = value['admin'][prop];
              group_render += `${indent}${indent}${indent}${prop} = ${val};\n`;
            }
            group_render += `${indent}${indent}}\n`;
          }
          if (value['task'] != null) {
            group_render += `${indent}${indent}task {\n`;
            for (const prop in value['task']) {
              const val = value['task'][prop];
              group_render += `${indent}${indent}${indent}${prop} = ${val};\n`;
            }
            group_render += `${indent}${indent}}\n`;
          }
          group_render += `${indent}}\n`;
        } else {
          group_render += `${indent}${key} {\n`;
          for (const prop in value) {
            const val = value[prop];
            group_render += `${indent}${indent}${prop} = ${val};\n`;
          }
          group_render += `${indent}}\n`;
        }
      }
      group_render += '}';
      count++;
      sections.push(group_render);
    }
    return sections.join("\n");
  }
};
