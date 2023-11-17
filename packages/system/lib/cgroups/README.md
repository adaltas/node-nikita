
# `nikita.system.cgroups`

Nikita action to manipulate cgroups. [cgconfig.conf(5)] describes the 
configuration file used by libcgroup to define control groups, their parameters 
and also mount points. The configuration file is identical on Ubuntu, RedHat 
and CentOS.

## Implementation

When reading the current config, nikita uses `cgsnapshot` command in order to
have a well formatted file. It is available on CentOS with the `libcgroup-tools`
package.

If docker is installed and started, informations about live containers could be
printed, that's why all path under  docker/* are ignored.

## Example

Example of a group object:

```
bibi:
  perm:
    admin:
      uid: 'bibi'
      gid: 'bibi'
    task:
      uid: 'bibi'
      gid: 'bibi'
  controllers:
    cpu:
      'cpu.rt_period_us': '"1000000"'
      'cpu.rt_runtime_us': '"0"'
      'cpu.cfs_period_us': '"100000"'
```

Which will result in a file:

```text
group bibi {
  perm {
    admin {
      uid = bibi;
      gid = bibi;
    }
    task {
      uid = bibi;
      gid = bibi;
    }
  }
  cpu {
    cpu.rt_period_us = "1000000";
    cpu.rt_runtime_us = "0";
    cpu.cfs_period_us = "100000";
  }
}
```
